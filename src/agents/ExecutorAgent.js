import { execFile } from 'child_process';
import path from 'path';
import { getDB } from '../database.js';

const ROOT = path.resolve('.');

class ExecutorAgent {
    async executeSteps(steps) {
        console.log(`⚙️  Executor Agent: Executing ${steps.length} steps...`);
        console.log("📝 Steps to execute:", JSON.stringify(steps, null, 2));
        
        return new Promise((resolve) => {
            const stepsJson = JSON.stringify(steps);
            console.log("🚀 Calling run_steps.sh with:", stepsJson.substring(0, 200), "...");
            
            execFile('./run_steps.sh', [stepsJson], { cwd: ROOT }, (err, stdout, stderr) => {
                if (err) {
                    console.error("❌ Executor Agent: run_steps.sh script error:", stderr);
                    return resolve({ success: [], failed: [{ title: "execution_error", stderr }], final_report_md: "Failed to execute steps." });
                }
                try {
                    const results = JSON.parse(stdout);
                    this.recordFailures(results.failed);
                    console.log(`✅ Executor Agent: Execution complete. Success: ${results.success.length}, Failed: ${results.failed.length}`);
                    resolve(results);
                } catch (e) {
                    console.error("❌ Executor Agent: Failed to parse run_steps.sh output:", e, stdout);
                    resolve({ success: [], failed: [{ title: "parse_error", stderr: e.message }], final_report_md: "Failed to parse execution results." });
                }
            });
        });
    }

    recordFailures(failedSteps) {
        if (!failedSteps || failedSteps.length === 0) return;
        const db = getDB();
        const upsertFailure = db.transaction((failures) => {
            const select = db.prepare('SELECT id, count FROM failures WHERE command_pattern = ?');
            const insert = db.prepare('INSERT INTO failures (command_pattern, command_example, error_message) VALUES (?, ?, ?)');
            const update = db.prepare('UPDATE failures SET count = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?');

            for (const step of failures) {
                const pattern = (step.bash || 'unknown').split(' ')[0]; // Simple pattern: first word
                const existing = select.get(pattern);
                if (existing) {
                    update.run(existing.count + 1, existing.id);
                } else {
                    insert.run(pattern, step.bash, step.stderr);
                }
            }
        });
        upsertFailure(failedSteps);
    }
}

export default new ExecutorAgent();
