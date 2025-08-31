import ModelManager from '../ModelManager.js';
import { getDB } from '../database.js';
import activityLogger from '../ActivityLogger.js';

class ConversationAgent {
    async respondToMessages(context, humanMessages, loopId = null) {
        if (!humanMessages || humanMessages.length === 0) return null;
        
        console.log("💬 Conversation Agent: Checking if response needed...");
        
        const conversationPrompt = `
You are a helpful autonomous agent. You've received messages from the human operator.

RULES:
1. Only respond if the human's messages contain questions, requests for help, or need clarification
2. Keep responses concise and helpful (under 100 words)
3. If they're giving you instructions or feedback, acknowledge briefly
4. If they ask about your status, explain what you're currently doing
5. Be friendly but professional
6. Return null if no response is needed

Human's recent messages:
${humanMessages.map(m => `- ${m.content}`).join('\n')}

Current context:
${context || 'No specific context available'}

Output: Return ONLY valid YAML:
response: "Your response here"
# Or if no response needed:
response: null
`;

        try {
            const result = await ModelManager.callAPI('CONVERSATION', conversationPrompt);
            
            if (result.response && result.response !== 'null') {
                console.log("💬 Sending response to human:", result.response);
                activityLogger.log(loopId, 'ConversationAgent', 'Responding to human', { response: result.response }, 'info');
                
                const db = getDB();
                db.prepare('INSERT INTO messages (source, content) VALUES (?, ?)').run('agent', result.response);
                
                // Mark human messages as read
                db.prepare("UPDATE messages SET is_read = 1 WHERE source = 'human' AND is_read = 0").run();
                
                return result.response;
            }
            
            activityLogger.log(loopId, 'ConversationAgent', 'No response needed', null, 'debug');
            return null;
        } catch (e) {
            console.error("❌ Conversation Agent: Failed to generate response.", e);
            activityLogger.log(loopId, 'ConversationAgent', 'Failed to generate response', { error: e.message }, 'error');
            return null;
        }
    }
    
    async askForHelp(issue, loopId = null) {
        // Agent can proactively ask for help when stuck
        console.log("🆘 Conversation Agent: Asking for help...");
        
        const db = getDB();
        const question = `I need help: ${issue}. Could you provide guidance?`;
        
        db.prepare('INSERT INTO messages (source, content) VALUES (?, ?)').run('agent', question);
        console.log("🆘 Asked human for help:", question);
        activityLogger.log(loopId, 'ConversationAgent', 'Asking for help', { issue: issue }, 'warning');
        
        return question;
    }
}

export default new ConversationAgent();