import 'dotenv/config';
import express from 'express';
import fs from 'fs-extra';
import path from 'path';
import { getDB, setup as setupDB } from './database.js';
import ModelManager from './ModelManager.js';
import ContextBuilder from './ContextBuilder.js';
import activityLogger from './ActivityLogger.js';
import PlannerAgent from './agents/PlannerAgent.js';
import ReviewerAgent from './agents/ReviewerAgent.js';
import ExecutorAgent from './agents/ExecutorAgent.js';
import ReflectorAgent from './agents/ReflectorAgent.js';
import MemoryAgent from './agents/MemoryAgent.js';
import SystemAgent from './agents/SystemAgent.js';
import ConversationAgent from './agents/ConversationAgent.js';

const { PORT, AUTO_APPROVE_RISK_THRESHOLD, MAX_APPROVED_STEPS_PER_LOOP, API_DELAY_MS, SYSTEM_AGENT_INTERVAL, DB_PATH } = process.env;

const ROOT = path.resolve('.');
const SITE_DIR = path.join(ROOT, 'site');

let isLoopRunning = false;
let loopCounter = 0;
let lastApiCall = 0;

// --- INITIALIZATION ---
fs.ensureDirSync(path.dirname(DB_PATH));
const db = getDB();
try {
    const tableCount = db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='missions'").get();
    if (!tableCount) {
        console.log("Database appears to be empty. Running initial setup...");
        setupDB();
    }
} catch (e) { console.error("DB setup check failed:", e); }

// Initialize activity logger
activityLogger.init();
activityLogger.log(null, 'system', 'Server starting', { port: PORT }, 'info');

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(SITE_DIR));


// --- HELPER FUNCTIONS ---
async function rateLimited(apiFunction) {
    const now = Date.now();
    const waitTime = API_DELAY_MS - (now - lastApiCall);
    if (waitTime > 0) {
        console.log(`⏱️  Rate limiting: waiting ${(waitTime/1000).toFixed(1)}s...`);
        await new Promise(resolve => setTimeout(resolve, waitTime));
    }
    const result = await apiFunction();
    lastApiCall = Date.now();
    return result;
}

// --- THE MAIN LOOP ---
async function oneLoop() {
    if (isLoopRunning) return;
    isLoopRunning = true;
    loopCounter++;
    const loopId = Date.now();
    console.log(`\n🚀 ===== Starting Loop #${loopCounter} (${loopId}) =====`);
    activityLogger.log(loopId, 'system', 'Loop started', { loopNumber: loopCounter }, 'info');

    try {
        db.prepare('INSERT INTO loops (id, status) VALUES (?, ?)').run(loopId, 'running');

        // 1. CONTEXT
        const { mission, fullContext, humanMessages } = ContextBuilder.buildContext();
        console.log(`🎯 Current Mission: ${mission.substring(0, 80)}...`);
        activityLogger.log(loopId, 'ContextBuilder', 'Context built', { 
            mission: mission,
            context_length: fullContext.length 
        }, 'info');
        
        // 1.5. CONVERSATION - Respond to human messages if needed
        if (humanMessages && humanMessages.length > 0) {
            activityLogger.log(loopId, 'ConversationAgent', 'Processing human messages', { count: humanMessages.length }, 'info');
            await ConversationAgent.respondToMessages(fullContext, humanMessages, loopId);
        }

        // 2. PLAN
        activityLogger.log(loopId, 'PlannerAgent', 'Generating plan', null, 'info');
        const plan = await rateLimited(() => PlannerAgent.generatePlan(fullContext, loopId));
        db.prepare('UPDATE loops SET plan_spec_md = ? WHERE id = ?').run(plan.spec_md, loopId);
        activityLogger.log(loopId, 'PlannerAgent', 'Plan generated', plan, 'success');

        // 3. REVIEW
        activityLogger.log(loopId, 'ReviewerAgent', 'Reviewing plan', null, 'info');
        const review = await rateLimited(() => ReviewerAgent.reviewPlan(plan));
        
        // DEBUG: Log raw review output
        console.log("📋 Raw review output:", JSON.stringify(review, null, 2));
        console.log(`📊 Review has ${review.approved_steps?.length || 0} approved steps before filtering`);
        
        const approvedSteps = (review.approved_steps || [])
            .filter(s => {
                const riskScore = s.risk?.score !== undefined ? s.risk.score : 1.0;
                const passes = riskScore <= AUTO_APPROVE_RISK_THRESHOLD;
                console.log(`   Step "${s.title}" risk: ${riskScore} (threshold: ${AUTO_APPROVE_RISK_THRESHOLD}) - ${passes ? 'PASS' : 'BLOCKED'}`);
                return passes;
            })
            .slice(0, MAX_APPROVED_STEPS_PER_LOOP);
        
        console.log(`✂️ After filtering: ${approvedSteps.length} steps approved for execution`);
        
        db.prepare('UPDATE loops SET review_summary_md = ? WHERE id = ?').run(review.summary_md, loopId);
        activityLogger.log(loopId, 'ReviewerAgent', 'Review complete', { 
            approved: approvedSteps.length, 
            rejected: (review.rejected || []).length,
            summary: review.summary_md,
            approved_steps: approvedSteps 
        }, 'success');
        
        // 4. EXECUTE
        let executionResults = { final_report_md: "No steps were approved for execution." };
        if (approvedSteps.length > 0) {
            activityLogger.log(loopId, 'ExecutorAgent', 'Executing steps', { count: approvedSteps.length }, 'info');
            executionResults = await ExecutorAgent.executeSteps(approvedSteps);
            activityLogger.log(loopId, 'ExecutorAgent', 'Execution complete', executionResults, 'success');
        } else {
            console.log("🤷 No steps approved or met risk threshold. Skipping execution.");
            activityLogger.log(loopId, 'ExecutorAgent', 'No steps to execute', null, 'warning');
        }
        db.prepare('UPDATE loops SET report_md = ? WHERE id = ?').run(executionResults.final_report_md, loopId);

        // 5. REFLECT
        activityLogger.log(loopId, 'ReflectorAgent', 'Generating reflection', null, 'info');
        const reflectionContext = `PLAN:\n${plan.spec_md}\n\nREVIEW:\n${review.summary_md}\n\nEXECUTION:\n${executionResults.final_report_md}`;
        const reflection = await rateLimited(() => ReflectorAgent.reflect(reflectionContext));
        db.prepare('UPDATE loops SET reflection_md = ? WHERE id = ?').run(reflection.reflection_md, loopId);
        activityLogger.log(loopId, 'ReflectorAgent', 'Reflection complete', { reflection: reflection.reflection_md }, 'success');
        
        // 6. MEMORIZE
        MemoryAgent.addMemory('reflection', reflection.reflection_md, loopId);
        if (executionResults.final_report_md) {
            MemoryAgent.addMemory('observation', `Execution summary: ${executionResults.final_report_md.substring(0, 200)}`, loopId);
        }
        activityLogger.log(loopId, 'MemoryAgent', 'Memories stored', { count: 2 }, 'info');

        // 7. EVOLVE (Periodic)
        if (loopCounter % SYSTEM_AGENT_INTERVAL === 0) {
            activityLogger.log(loopId, 'SystemAgent', 'Running improvement check', null, 'info');
            await SystemAgent.runImprovementCheck();
        }
        
        db.prepare('UPDATE loops SET status = ? WHERE id = ?').run('completed', loopId);
        activityLogger.log(loopId, 'system', 'Loop completed successfully', null, 'success');
    } catch (error) {
        console.error(`❌ Loop ${loopId} failed catastrophically:`, error);
        activityLogger.log(loopId, 'system', 'Loop failed', { error: error.message }, 'error');
        db.prepare('UPDATE loops SET status = ?, report_md = ? WHERE id = ?').run('failed', error.message, loopId);
    } finally {
        await updateSite();
        isLoopRunning = false;
        console.log(`✅ ===== Finished Loop #${loopCounter} =====`);
    }
}

// --- DASHBOARD & API ---
app.get('/', (req, res) => {
    res.redirect('/dashboard.html');
});

async function updateSite() {
    const lastLoop = db.prepare('SELECT * FROM loops ORDER BY id DESC LIMIT 1').get();
    const allMessages = db.prepare(`
        SELECT source, content, created_at FROM messages 
        ORDER BY created_at DESC LIMIT 20
    `).all();
    
    // Build conversation history HTML
    const conversationHtml = allMessages.map(m => {
        const isAgent = m.source === 'agent';
        const color = isAgent ? '#58a6ff' : '#7ee83f';
        const prefix = isAgent ? '🤖' : '👤';
        return `<div style="margin:0.5rem 0;padding:0.5rem;background:${isAgent?'#0d1117':'#161b22'};border-left:3px solid ${color}">
            <small style="color:#6e7681">${new Date(m.created_at).toLocaleString()}</small><br>
            <strong style="color:${color}">${prefix} ${isAgent?'Agent':'Human'}:</strong> ${m.content}
        </div>`;
    }).join('') || '<p>No messages yet</p>';
    
    const indexHtml = `<!DOCTYPE html><html lang="en"><head><title>GAA-4.0 Dashboard</title><style>
body{font-family:monospace;background:#0d1117;color:#c9d1d9;margin:2rem}
h1,h2,h3{color:#58a6ff}
.container{max-width:1200px;margin:0 auto}
.box{background:#161b22;border:1px solid #30363d;padding:1rem;margin-bottom:1rem;border-radius:6px}
pre{white-space:pre-wrap;word-wrap:break-word;background:#010409;padding:1rem;border-radius:4px}
textarea{width:98%;height:80px;background:#21262d;color:#c9d1d9;border:1px solid #30363d;padding:0.5rem;font-family:monospace;resize:vertical}
button{width:98%;background:#238636;color:#fff;border:none;padding:0.75rem;cursor:pointer;font-weight:bold;border-radius:4px;margin-top:0.5rem}
button:hover{background:#2ea043}
.conversation{max-height:400px;overflow-y:auto;padding:0.5rem;background:#010409;border-radius:4px}
.status{display:flex;justify-content:space-around;text-align:center}
.status-item{flex:1;padding:0.5rem}
</style></head><body>
<div class="container">
<h1>🤖 GAA-4.0 Testing Dashboard</h1>
<div class="box">
    <h2>System Status</h2>
    <div class="status">
        <div class="status-item"><strong>Loop #</strong><br>${loopCounter}</div>
        <div class="status-item"><strong>Status</strong><br>${lastLoop?.status || 'N/A'}</div>
        <div class="status-item"><strong>Last Run</strong><br>${lastLoop?.id ? new Date(lastLoop.id).toLocaleTimeString() : 'N/A'}</div>
    </div>
</div>
<div class="box">
    <h2>💬 Conversation</h2>
    <div class="conversation">${conversationHtml}</div>
    <form action="/messages" method="post">
        <textarea name="content" placeholder="Type your message to the agent..." required></textarea>
        <button type="submit">📤 Send Message</button>
    </form>
</div>
<div class="box">
    <h2>Last Reflection</h2>
    <pre>${lastLoop?.reflection_md || 'No reflection yet'}</pre>
</div>
</div>
</body></html>`;
    await fs.outputFile(path.join(SITE_DIR, 'index.html'), indexHtml);
}

// --- SSE SUPPORT ---
const sseClients = new Set();

app.get('/events', (req, res) => {
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');
    
    // Send initial connection message
    res.write('data: {"type":"connected"}\n\n');
    
    // Add client to set
    sseClients.add(res);
    
    // Send heartbeat every 30 seconds
    const heartbeat = setInterval(() => {
        res.write('data: {"type":"heartbeat"}\n\n');
    }, 30000);
    
    // Handle client disconnect
    req.on('close', () => {
        sseClients.delete(res);
        clearInterval(heartbeat);
        activityLogger.log(null, 'system', 'SSE client disconnected', null, 'debug');
    });
});

// Broadcast function for SSE
function broadcastSSE(eventType, data) {
    const message = JSON.stringify({ type: eventType, data, timestamp: new Date().toISOString() });
    sseClients.forEach(client => {
        client.write(`data: ${message}\n\n`);
    });
}

// Listen to activity logger events
activityLogger.on('activity', (activity) => {
    broadcastSSE('activity', activity);
});

// --- API ENDPOINTS ---
app.get('/api/status', (req, res) => {
    const lastLoop = db.prepare('SELECT * FROM loops ORDER BY id DESC LIMIT 1').get();
    const loopCount = db.prepare('SELECT COUNT(*) as count FROM loops').get();
    const missionCount = db.prepare('SELECT COUNT(*) as count FROM missions WHERE is_complete = 0').get();
    
    res.json({
        loopNumber: loopCounter,
        isRunning: isLoopRunning,
        lastLoop,
        totalLoops: loopCount.count,
        activeMissions: missionCount.count
    });
});

app.get('/api/activities', (req, res) => {
    const limit = parseInt(req.query.limit) || 100;
    const activities = activityLogger.getRecent(limit);
    res.json(activities);
});

app.get('/api/reflections', (req, res) => {
    const reflections = db.prepare(`
        SELECT id, reflection_md, created_at 
        FROM loops 
        WHERE reflection_md IS NOT NULL 
        ORDER BY id DESC 
        LIMIT 20
    `).all();
    res.json(reflections);
});

app.get('/api/messages', (req, res) => {
    const messages = db.prepare(`
        SELECT * FROM messages 
        ORDER BY created_at DESC 
        LIMIT 50
    `).all();
    res.json(messages);
});

app.post('/messages', (req, res) => {
    const { content } = req.body;
    if (content) {
        db.prepare('INSERT INTO messages (source, content) VALUES (?, ?)').run('human', content);
        broadcastSSE('message', { source: 'human', content });
    }
    res.redirect('/');
});

app.listen(PORT, () => {
    console.log(`\n✅ GAA-4.0 Server (Docker-Native) listening on http://localhost:${PORT}`);
    updateSite();
    setInterval(oneLoop, 5000); // Trigger loop automatically
});

// Cleanup on shutdown
process.on('SIGTERM', () => {
    activityLogger.close();
    db.close();
    process.exit(0);
});
