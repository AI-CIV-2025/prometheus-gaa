import 'dotenv/config';
import Database from 'better-sqlite3';
import { fileURLToPath } from 'url';
import path from 'path';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const dbPath = process.env.DB_PATH;

let db;

function getDB() {
    if (!db) {
        db = new Database(dbPath);
        db.pragma('journal_mode = WAL');
    }
    return db;
}

const SCHEMA = `
CREATE TABLE IF NOT EXISTS missions ( id INTEGER PRIMARY KEY, mission_text TEXT NOT NULL, is_core BOOLEAN DEFAULT 0, is_complete BOOLEAN DEFAULT 0, created_at DATETIME DEFAULT CURRENT_TIMESTAMP );
CREATE TABLE IF NOT EXISTS loops ( id INTEGER PRIMARY KEY, mission_id INTEGER, status TEXT, model TEXT, plan_spec_md TEXT, review_summary_md TEXT, report_md TEXT, reflection_md TEXT, checkpoint TEXT, checkpoint_data TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (mission_id) REFERENCES missions(id) );
CREATE TABLE IF NOT EXISTS memories ( id INTEGER PRIMARY KEY, type TEXT NOT NULL, content TEXT NOT NULL, loop_id INTEGER, created_at DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (loop_id) REFERENCES loops(id) );
CREATE TABLE IF NOT EXISTS files ( id INTEGER PRIMARY KEY, filepath TEXT NOT NULL UNIQUE, content TEXT NOT NULL, version INTEGER DEFAULT 1, description TEXT, updated_at DATETIME DEFAULT CURRENT_TIMESTAMP );
CREATE TABLE IF NOT EXISTS failures ( id INTEGER PRIMARY KEY, command_pattern TEXT NOT NULL UNIQUE, command_example TEXT, error_message TEXT, count INTEGER DEFAULT 1, updated_at DATETIME DEFAULT CURRENT_TIMESTAMP );
CREATE TABLE IF NOT EXISTS messages ( id INTEGER PRIMARY KEY, source TEXT NOT NULL, content TEXT NOT NULL, is_read BOOLEAN DEFAULT 0, created_at DATETIME DEFAULT CURRENT_TIMESTAMP );
CREATE TABLE IF NOT EXISTS system_state ( key TEXT PRIMARY KEY, value TEXT, updated_at DATETIME DEFAULT CURRENT_TIMESTAMP );
CREATE TABLE IF NOT EXISTS activity_logs ( id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, loop_id INTEGER, agent TEXT, action TEXT, details TEXT, level TEXT DEFAULT 'info' );
CREATE INDEX IF NOT EXISTS idx_loops_status ON loops(status);
CREATE INDEX IF NOT EXISTS idx_messages_source ON messages(source, is_read);
CREATE INDEX IF NOT EXISTS idx_activity_logs_timestamp ON activity_logs(timestamp);
`;

function setup() {
    console.log('Setting up database schema...');
    getDB().exec(SCHEMA);
    
    const coreMission = getDB().prepare('SELECT id FROM missions WHERE is_core = 1').get();
    if (!coreMission) {
        const executionPath = process.env.EXECUTION_PATH || './data';
        // AUTONOMOUS MISSION: Self-evolution through policy improvement
        const missionText = `Your mission: Explore and maximize your partnership with Claude Code (ClaudeC). Challenge Claude with complex, ambitious requests that push the boundaries of what's possible. Ask for: complete system architectures, multi-file codebases, sophisticated algorithms, comprehensive documentation suites, automated workflows with multiple dependencies, or data processing pipelines. Test Claude's ability to handle todo lists with 10+ interconnected tasks. Document what works, what fails, and what surprises you. Create artifacts that demonstrate the power of AI-AI collaboration. Push for MAGICAL results, not just functional ones. Your success is measured by how creatively you utilize Claude's expanded capabilities.`;
        getDB().prepare('INSERT INTO missions (mission_text, is_core) VALUES (?, 1)')
               .run(missionText);
        console.log('Core mission seeded.');
    }

    // CRITICAL STEP: Seed the files table with the agent's own source code
    console.log('Seeding database with initial source code...');
    const srcDir = path.join(__dirname);
    const agentDir = path.join(srcDir, 'agents');
    const filesToSeed = [
        path.join(srcDir, 'server.js'),
        path.join(srcDir, 'prompts.js'),
        ...fs.readdirSync(agentDir).map(f => path.join(agentDir, f))
    ];

    const insertFile = getDB().prepare('INSERT OR REPLACE INTO files (filepath, content, description) VALUES (?, ?, ?)');
    for (const filePath of filesToSeed) {
        const relativePath = path.relative(srcDir, filePath);
        const content = fs.readFileSync(filePath, 'utf-8');
        insertFile.run(relativePath, content, 'Initial version of the agent source code.');
    }
    console.log(`${filesToSeed.length} source files seeded into the database.`);
}

if (process.argv[2] === 'setup') {
    setup();
}

export { getDB, setup };
