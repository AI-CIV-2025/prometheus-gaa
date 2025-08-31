import { exec } from 'child_process';
import util from 'util';
import fs from 'fs-extra';
import path from 'path';
import { getDB } from '../database.js';
import activityLogger from '../ActivityLogger.js';

const execAsync = util.promisify(exec);
const SANDBOX_DIR = '/tmp/gaa_sandbox';

class TesterAgent {
    async runTestInSandbox(patch) {
        activityLogger.log(null, 'TesterAgent', `Initializing sandbox test for patch on ${patch.file}`, patch, 'info');
        console.log(`🧪 Tester Agent: Initializing sandbox test for patch on ${patch.file}...`);
        
        const testId = `test-${Date.now()}`;
        const sandboxPath = path.join(SANDBOX_DIR, testId);
        const imageName = `gaa-sandbox:${testId}`;

        try {
            // 1. Setup sandbox directory
            await fs.ensureDir(sandboxPath);
            await this.createSandboxFileSystem(sandboxPath, patch);

            // 2. Build the sandbox Docker image
            console.log(`🧪 Tester Agent: Building sandbox image '${imageName}'...`);
            await execAsync(`docker build -t ${imageName} -f ${path.join(sandboxPath, 'Dockerfile.sandbox')} ${sandboxPath}`);

            // 3. Run the test container
            console.log(`🧪 Tester Agent: Running sandbox container with functional test...`);
            const { stdout, stderr } = await execAsync(`docker run --rm ${imageName}`);
            
            console.log(`✅ Tester Agent: Sandbox test PASSED for ${patch.file}.`);
            activityLogger.log(null, 'TesterAgent', 'Test passed', { file: patch.file, stdout, stderr }, 'success');
            return { passed: true, logs: stdout || "Test completed successfully with exit code 0." };

        } catch (error) {
            console.error(`❌ Tester Agent: Sandbox test FAILED for ${patch.file}.`);
            console.error(`   Error: ${error.stderr || error.message}`);
            activityLogger.log(null, 'TesterAgent', 'Test failed', { file: patch.file, error: error.stderr || error.message }, 'error');
            return { passed: false, logs: error.stderr || error.message };
        } finally {
            // 4. Cleanup
            console.log(`🧹 Tester Agent: Cleaning up sandbox resources...`);
            await execAsync(`docker rmi -f ${imageName}`).catch(err => console.error(`   Warning: Could not remove image ${imageName}.`));
            await fs.remove(sandboxPath);
            console.log(`✅ Tester Agent: Cleanup complete.`);
        }
    }

    async createSandboxFileSystem(sandboxPath, patch) {
        // Copy all current source code from DB to the sandbox dir
        const db = getDB();
        const allFiles = db.prepare('SELECT filepath, content FROM files').all();
        for (const file of allFiles) {
            const destPath = path.join(sandboxPath, 'src', file.filepath);
            await fs.outputFile(destPath, file.content);
        }

        // Apply the patch
        const patchedFilePath = path.join(sandboxPath, 'src', patch.file);
        const originalContent = await fs.readFile(patchedFilePath, 'utf-8');
        const newContent = originalContent.replace(patch.old_code, patch.new_code);
        await fs.writeFile(patchedFilePath, newContent);

        // Create a simple package.json for the sandbox
        await fs.copyFile('package.json', path.join(sandboxPath, 'package.json'));
        
        // Create the test script if provided
        let testCommand = `node --check "${patch.file}"`;  // Default syntax check
        
        if (patch.test_case) {
            // Write the test case to a file
            const testFile = 'test_patch.js';
            await fs.writeFile(path.join(sandboxPath, 'src', testFile), patch.test_case);
            testCommand = `node ${testFile}`;  // Run the functional test
            
            console.log(`🧪 Tester Agent: Using functional test from patch.test_case`);
        } else {
            console.log(`🧪 Tester Agent: No test_case provided, using syntax check only`);
        }
        
        // Create the sandbox Dockerfile
        const dockerfileContent = `
FROM node:20-slim
WORKDIR /app
COPY package.json .
RUN npm install --production
COPY src/ .

# Run either the functional test or syntax check
CMD ["${testCommand.split(' ')[0]}", "${testCommand.split(' ').slice(1).join('", "')}"]
`;
        await fs.writeFile(path.join(sandboxPath, 'Dockerfile.sandbox'), dockerfileContent);
    }

    // New method for non-Docker testing (for local development)
    async runLocalTest(patch) {
        if (!patch.test_case) {
            console.log(`⚠️ No test_case provided for local testing`);
            return { passed: false, logs: "No test_case provided" };
        }

        const testFile = path.join(SANDBOX_DIR, `test-${Date.now()}.js`);
        
        try {
            await fs.ensureDir(SANDBOX_DIR);
            await fs.writeFile(testFile, patch.test_case);
            
            console.log(`🧪 Running local test: ${testFile}`);
            const { stdout, stderr } = await execAsync(`node ${testFile}`);
            
            console.log(`✅ Local test PASSED`);
            return { passed: true, logs: stdout || "Test passed" };
            
        } catch (error) {
            console.error(`❌ Local test FAILED: ${error.message}`);
            return { passed: false, logs: error.stderr || error.message };
            
        } finally {
            await fs.remove(testFile).catch(() => {});
        }
    }
}

export default new TesterAgent();