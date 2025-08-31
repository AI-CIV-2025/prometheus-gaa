import { getDB } from './database.js';
import fs from 'fs-extra';

class ContextBuilder {
    buildContext() {
        const db = getDB();
        
        const mission = db.prepare(`
            SELECT mission_text FROM missions 
            WHERE is_complete = 0 
            ORDER BY is_core DESC, created_at DESC LIMIT 1
        `).get();
        
        // CRITICAL: Get the last loop's execution report to provide feedback
        const lastLoop = db.prepare(`
            SELECT report_md, status FROM loops
            ORDER BY created_at DESC LIMIT 1
        `).get();
        
        const recentMemories = db.prepare(`
            SELECT content FROM memories 
            ORDER BY created_at DESC LIMIT 5
        `).all();
        
        const recentFailures = db.prepare(`
            SELECT command_pattern, error_message, count FROM failures
            ORDER BY updated_at DESC LIMIT 3
        `).all();

        const humanMessages = db.prepare(`
            SELECT content FROM messages
            WHERE source = 'human' AND is_read = 0
            ORDER BY created_at ASC
        `).all();

        let context = '';
        
        // CRITICAL FEEDBACK LOOP: If last execution failed, make that the TOP priority
        if (lastLoop && lastLoop.report_md && lastLoop.report_md.includes('FAILED')) {
            context += `## 🚨 CRITICAL: PREVIOUS EXECUTION FAILED\n`;
            context += `The last plan failed with errors. Your PRIMARY GOAL is to fix these errors.\n`;
            context += `\nLAST EXECUTION REPORT:\n\`\`\`\n${lastLoop.report_md}\n\`\`\`\n\n`;
            context += `Analyze the error messages above and adapt your approach to avoid the same failure.\n\n`;
        }
        
        context += `## Core Mission\n${mission.mission_text}\n\n`;

        if (recentMemories.length > 0) {
            context += `## Recent Memories / Lessons\n`;
            context += recentMemories.map(m => `- ${m.content}`).join('\n') + '\n\n';
        }

        if (recentFailures.length > 0) {
            context += `## Recurring Failures to Avoid\n`;
            context += recentFailures.map(f => `- '${f.command_pattern}' failed ${f.count} times with error: ${f.error_message}`).join('\n') + '\n\n';
        }

        if (humanMessages.length > 0) {
            context += `## New Messages from Human Operator\n`;
            context += humanMessages.map(m => `- ${m.content}`).join('\n') + '\n\n';
            // Don't mark as read here - let ConversationAgent do it after responding
        }

        // Add execution environment and policy to context
        const executionPath = process.env.EXECUTION_PATH || './data';
        context += `## System Environment\n`;
        context += `EXECUTION_PATH: ${executionPath}\n`;
        context += `CRITICAL: All file operations MUST use the path '${executionPath}' instead of '/app/data' or any other path.\n`;
        context += `Example: To create a file, use: echo "content" > ${executionPath}/filename.txt\n`;
        context += `TIP: Use 'ls -la ${executionPath}' to see what files you've already created.\n\n`;
        
        try {
            const policy = fs.readJsonSync('./exec_policy.json');
            const allowedCommands = [...policy.allow_bins, ...policy.allow_net_bins];
            context += `## System Execution Policy\n`;
            context += `IMPORTANT: You may only use the following commands: ${allowedCommands.join(', ')}.\n`;
            context += `All other commands will be rejected. Focus on file operations (echo, cat, ls, touch) and analysis.\n\n`;
        } catch (e) {
            console.error("Could not read exec_policy.json:", e.message);
        }

        return { mission: mission.mission_text, fullContext: context, humanMessages };
    }
}

export default new ContextBuilder();
