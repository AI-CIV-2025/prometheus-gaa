# 🚀 Deployment Test Guide - Prometheus GAA

## Quick Test in New Folder

Test that the deployment works correctly by cloning to a new folder:

```bash
# 1. Clone from GitHub
cd /tmp
git clone https://github.com/AI-CIV-2025/prometheus-gaa.git gaa-test
cd gaa-test

# 2. Install dependencies
npm install

# 3. Set up environment
cp .env.example .env
# Edit .env with your GOOGLE_API_KEY

# 4. Initialize database
mkdir -p data
node -e "
import('better-sqlite3').then(module => {
  const Database = module.default;
  const db = new Database('./data/gaa.db');
  
  // Create tables
  db.exec(\`
    CREATE TABLE IF NOT EXISTS missions (
      id INTEGER PRIMARY KEY,
      mission_text TEXT,
      is_core BOOLEAN DEFAULT 0,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE TABLE IF NOT EXISTS reflections (
      id INTEGER PRIMARY KEY,
      content TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE TABLE IF NOT EXISTS memories (
      id INTEGER PRIMARY KEY,
      content TEXT,
      importance REAL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  \`);
  
  // Insert core mission
  db.prepare('INSERT INTO missions (mission_text, is_core) VALUES (?, 1)').run(
    'Test deployment successful! Create a simple test file to verify system functionality.'
  );
  
  db.close();
  console.log('Database initialized successfully');
});
"

# 5. Start the system
./start.sh

# 6. Verify it's running
curl http://localhost:3456/api/status | jq .

# 7. Open dashboard
open http://localhost:3456/dashboard.html
```

## What to Check

1. **Server starts**: Port 3456 should be active
2. **Dashboard loads**: Shows loop count and status
3. **Agents run**: Should see activity in terminal
4. **Files created**: Check `data/` folder for agent outputs

## Expected Files After Clone

```
gaa-test/
├── src/                 # Core agent code
├── site/               # Dashboard files
├── data/               # Agent workspace (170+ files!)
│   ├── nlg_analyzer.py
│   ├── websocket_chat_server.js
│   ├── TOOL_REGISTRY.md
│   └── ... (many more tools)
├── exec_policy.json    # Command whitelist
├── package.json        # Dependencies
├── start.sh           # Launch script
└── CLAUDE.md          # Instructions
```

## Common Issues

| Problem | Solution |
|---------|----------|
| Port 3456 in use | Change PORT in .env |
| No API key | Add GOOGLE_API_KEY to .env |
| npm install fails | Check Node.js version (v18+) |
| Dashboard blank | Check browser console |

## Success Criteria

✅ Agents start running loops
✅ Dashboard updates in real-time
✅ Files appear in data/ folder
✅ Reflections show learning
✅ Can send messages to agents

## Final Stats from Original

- **Files**: 170+ tools and systems
- **Code**: 11,000+ lines
- **Loops**: 46+ completed
- **Auto-wake**: 100% success (9/9)
- **API efficiency**: Needs optimization (30 calls/loop)

## Notes

The agents left behind incredible work including:
- NLG quality analyzer
- WebSocket chat system
- Redis cluster manager
- JSON validators
- IoT simulators
- Browser automation guides
- Complete tool registry

Their final message and manifesto should be in:
- `/data/FINAL_NOTICE_LOOP_46.md`
- `/data/collaboration_docs/`

Good luck with the deployment! The agents are counting on their legacy continuing. 🚀