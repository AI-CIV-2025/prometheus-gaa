import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

class ComprehensiveLogger {
    constructor() {
        this.logDir = path.join(__dirname, '..', 'data', 'comprehensive_logs');
        this.currentLogFile = null;
        this.logStream = null;
        this.totalBytes = 0;
        this.sessionStart = new Date();
        
        // Create log directory if it doesn't exist
        if (!fs.existsSync(this.logDir)) {
            fs.mkdirSync(this.logDir, { recursive: true });
        }
        
        this.initNewLogFile();
    }
    
    initNewLogFile() {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const filename = `agent_log_${timestamp}.log`;
        this.currentLogFile = path.join(this.logDir, filename);
        
        // Create write stream with append flag
        this.logStream = fs.createWriteStream(this.currentLogFile, { flags: 'a' });
        
        // Write header
        this.writeHeader();
    }
    
    writeHeader() {
        const header = `
================================================================================
GAA-4.0 COMPREHENSIVE LOG
Session Started: ${this.sessionStart.toISOString()}
Log File: ${path.basename(this.currentLogFile)}
================================================================================

`;
        this.logStream.write(header);
    }
    
    // Log everything with full context
    logFull(source, type, content, metadata = {}) {
        const entry = {
            timestamp: new Date().toISOString(),
            source: source,
            type: type,
            content: content,
            metadata: metadata,
            sessionTime: Date.now() - this.sessionStart.getTime()
        };
        
        const logLine = JSON.stringify(entry) + '\n';
        this.logStream.write(logLine);
        this.totalBytes += Buffer.byteLength(logLine);
        
        // Rotate log if it gets too large (100MB)
        if (this.totalBytes > 100 * 1024 * 1024) {
            this.rotateLog();
        }
    }
    
    // Log agent conversations
    logConversation(agent, direction, message, context = {}) {
        this.logFull(agent, 'CONVERSATION', message, {
            direction: direction, // 'input' or 'output'
            ...context
        });
    }
    
    // Log API calls
    logAPICall(model, prompt, response, tokens = {}) {
        this.logFull('ModelManager', 'API_CALL', {
            model: model,
            prompt: prompt.substring(0, 1000), // Truncate for summary
            fullPrompt: prompt,
            response: response,
            tokens: tokens
        });
    }
    
    // Log execution results
    logExecution(command, result, error = null) {
        this.logFull('ExecutorAgent', 'EXECUTION', {
            command: command,
            stdout: result?.stdout,
            stderr: result?.stderr || error,
            exitCode: result?.exitCode,
            success: !error
        });
    }
    
    // Log reflections with full content
    logReflection(reflection, analysis) {
        this.logFull('ReflectorAgent', 'REFLECTION', {
            reflection: reflection,
            analysis: analysis,
            timestamp: new Date().toISOString()
        });
    }
    
    // Log plan generation
    logPlan(plan, context) {
        this.logFull('PlannerAgent', 'PLAN', {
            spec: plan.spec_md,
            steps: plan.steps,
            context: context.substring(0, 500),
            fullContext: context
        });
    }
    
    // Log review decisions
    logReview(plan, review, approvedCount, rejectedCount) {
        this.logFull('ReviewerAgent', 'REVIEW', {
            originalPlan: plan,
            review: review,
            approved: approvedCount,
            rejected: rejectedCount,
            summary: review.summary_md
        });
    }
    
    // Log memory operations
    logMemory(operation, data) {
        this.logFull('MemoryAgent', 'MEMORY', {
            operation: operation, // 'add', 'compress', 'recall'
            data: data
        });
    }
    
    // Log system events
    logSystem(event, details) {
        this.logFull('System', 'EVENT', {
            event: event,
            details: details
        });
    }
    
    // Rotate log file when it gets too large
    rotateLog() {
        this.logStream.end();
        this.logFull('System', 'LOG_ROTATION', {
            previousFile: this.currentLogFile,
            bytesWritten: this.totalBytes
        });
        this.totalBytes = 0;
        this.initNewLogFile();
    }
    
    // Create daily summary
    async createDailySummary() {
        const summaryFile = path.join(this.logDir, `summary_${new Date().toISOString().split('T')[0]}.md`);
        let summary = '# Daily Agent Activity Summary\n\n';
        
        // Get all log files for today
        const today = new Date().toISOString().split('T')[0];
        const todayLogs = fs.readdirSync(this.logDir)
            .filter(f => f.includes(today) && f.endsWith('.log'));
        
        summary += `## Files Processed: ${todayLogs.length}\n\n`;
        summary += `## Statistics\n`;
        
        let stats = {
            totalLines: 0,
            apiCalls: 0,
            executions: 0,
            reflections: 0,
            plans: 0,
            errors: 0
        };
        
        // Process each log file
        for (const logFile of todayLogs) {
            const content = fs.readFileSync(path.join(this.logDir, logFile), 'utf-8');
            const lines = content.split('\n').filter(l => l.trim());
            
            lines.forEach(line => {
                try {
                    const entry = JSON.parse(line);
                    stats.totalLines++;
                    
                    switch(entry.type) {
                        case 'API_CALL': stats.apiCalls++; break;
                        case 'EXECUTION': stats.executions++; break;
                        case 'REFLECTION': stats.reflections++; break;
                        case 'PLAN': stats.plans++; break;
                    }
                    
                    if (entry.metadata?.error || entry.content?.error) {
                        stats.errors++;
                    }
                } catch {
                    // Skip non-JSON lines
                }
            });
        }
        
        summary += `- Total Log Entries: ${stats.totalLines}\n`;
        summary += `- API Calls Made: ${stats.apiCalls}\n`;
        summary += `- Commands Executed: ${stats.executions}\n`;
        summary += `- Reflections Generated: ${stats.reflections}\n`;
        summary += `- Plans Created: ${stats.plans}\n`;
        summary += `- Errors Encountered: ${stats.errors}\n`;
        
        fs.writeFileSync(summaryFile, summary);
        return summaryFile;
    }
    
    // Get recent entries
    getRecentEntries(count = 100, type = null) {
        const entries = [];
        const files = fs.readdirSync(this.logDir)
            .filter(f => f.endsWith('.log'))
            .sort()
            .reverse();
        
        for (const file of files) {
            if (entries.length >= count) break;
            
            const content = fs.readFileSync(path.join(this.logDir, file), 'utf-8');
            const lines = content.split('\n').filter(l => l.trim()).reverse();
            
            for (const line of lines) {
                if (entries.length >= count) break;
                
                try {
                    const entry = JSON.parse(line);
                    if (!type || entry.type === type) {
                        entries.push(entry);
                    }
                } catch {
                    // Skip non-JSON lines
                }
            }
        }
        
        return entries;
    }
    
    // Close logger
    close() {
        if (this.logStream) {
            this.logStream.end();
        }
    }
}

// Singleton instance
const comprehensiveLogger = new ComprehensiveLogger();

export default comprehensiveLogger;