import { getDB } from '../database.js';
import ModelManager from '../ModelManager.js';
import TesterAgent from './TesterAgent.js';
import activityLogger from '../ActivityLogger.js';

class SystemAgent {
    async runImprovementCheck() {
        console.log("🤖 System Agent: Running self-improvement check...");
        activityLogger.log(null, 'SystemAgent', 'Starting self-improvement check', {}, 'info');
        
        const db = getDB();
        const topFailure = db.prepare('SELECT * FROM failures ORDER BY count DESC LIMIT 1').get();

        if (!topFailure || topFailure.count < 3) {
            console.log("🤖 System Agent: No significant failure patterns found.");
            return;
        }

        console.log(`🤖 System Agent: Found recurring failure pattern: '${topFailure.command_pattern}'`);
        activityLogger.log(null, 'SystemAgent', 'Found recurring failure', topFailure, 'warning');

        // Improved heuristic to guess the responsible file
        const responsibleFile = this.guessResponsibleFile(topFailure.command_pattern, topFailure.error_message);
        const fileContent = db.prepare('SELECT content FROM files WHERE filepath = ?').get(responsibleFile);

        if (!fileContent) {
            console.error(`🤖 System Agent: Could not find source code for '${responsibleFile}'.`);
            activityLogger.log(null, 'SystemAgent', 'Source file not found', { file: responsibleFile }, 'error');
            return;
        }
        
        const context = `FAILURE PATTERN:\n${JSON.stringify(topFailure, null, 2)}\n\nSOURCE CODE of ${responsibleFile}:\n${fileContent.content}`;
        
        try {
            const result = await ModelManager.callAPI('SYSTEM_AGENT', context);
            
            if (result.patch) {
                console.log(`🤖 System Agent: Proposing patch for ${result.patch.file}...`);
                activityLogger.log(null, 'SystemAgent', 'Proposing patch', result, 'info');
                
                // Check if the patch is trying to modify security files
                const securityFiles = ['run_steps.sh', 'exec_policy.json', 'Dockerfile.sandbox'];
                if (securityFiles.includes(result.patch.file) || 
                    result.patch.file.includes('run_steps') || 
                    result.patch.file.includes('exec_policy')) {
                    console.error("🚫 System Agent: Patch attempts to modify security file. REJECTED.");
                    activityLogger.log(null, 'SystemAgent', 'Security violation - patch rejected', result.patch, 'error');
                    return;
                }
                
                // Add test_case to patch if provided
                const patchWithTest = {
                    ...result.patch,
                    test_case: result.test_case || null
                };
                
                // Test the patch
                const testResult = await TesterAgent.runLocalTest(patchWithTest);
                
                if (testResult.passed) {
                    console.log("✅ System Agent: Patch passed tests! Applying to database.");
                    activityLogger.log(null, 'SystemAgent', 'Patch passed tests', { patch: patchWithTest, testResult }, 'success');
                    
                    // Apply the patch to the file in database
                    const originalContent = fileContent.content;
                    const newContent = originalContent.replace(result.patch.old_code, result.patch.new_code);
                    
                    db.prepare('UPDATE files SET content = ?, version = version + 1, updated_at = CURRENT_TIMESTAMP WHERE filepath = ?')
                      .run(newContent, result.patch.file);
                    
                    // Reset the failure count since we (hopefully) fixed it
                    db.prepare('DELETE FROM failures WHERE id = ?').run(topFailure.id);
                    
                    console.log("🚨 System Agent: Code updated. A restart is required for changes to take effect.");
                    activityLogger.log(null, 'SystemAgent', 'Patch applied - restart required', { file: result.patch.file }, 'success');
                    
                } else {
                    console.error("❌ System Agent: Patch failed tests. Discarding.", testResult.logs);
                    activityLogger.log(null, 'SystemAgent', 'Patch failed tests', { patch: patchWithTest, testResult }, 'error');
                }
            } else {
                console.log("🤖 System Agent: No patch generated.");
            }
        } catch(e) {
            console.error("❌ System Agent: Failed to generate a patch.", e);
            activityLogger.log(null, 'SystemAgent', 'Failed to generate patch', { error: e.message }, 'error');
        }
    }

    guessResponsibleFile(command, errorMessage) {
        // Improved heuristic based on error patterns
        
        // If it's a policy denial, the planner needs fixing
        if (errorMessage && errorMessage.includes('denied by policy')) {
            console.log("🤖 System Agent: Policy denial detected - targeting PlannerAgent");
            return 'agents/PlannerAgent.js';
        }
        
        // If it's a command not in whitelist, update prompts
        if (errorMessage && errorMessage.includes('not in the allowed list')) {
            console.log("🤖 System Agent: Command not allowed - targeting prompts");
            return 'prompts.js';
        }
        
        // Execution failures might be executor issues
        if (errorMessage && errorMessage.includes('execution')) {
            return 'agents/ExecutorAgent.js';
        }
        
        // YAML parsing errors
        if (errorMessage && (errorMessage.includes('YAML') || errorMessage.includes('parse'))) {
            return 'ModelManager.js';
        }
        
        // Default: Bad plans are a common source of error
        return 'agents/PlannerAgent.js';
    }
}

export default new SystemAgent();