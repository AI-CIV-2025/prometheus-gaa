# GAA-5-Testing - Current Working System

## 🚀 Quick Start

```bash
# Start the system
npm start

# Check status
curl http://localhost:3456/api/status | jq .

# View dashboard
open http://localhost:3456/dashboard.html
```

## 📁 Active Core Files

### Main System Components
- `src/server.js` - Express server, main loop coordinator
- `src/database.js` - SQLite database interface
- `src/ModelManager.js` - Gemini API management
- `src/prompts.js` - All agent personalities/prompts
- `src/ContextBuilder.js` - Context assembly for agents
- `src/ActivityLogger.js` - Centralized event logging

### Agent Files (src/agents/)
- `PlannerAgent.js` - Creates YAML plans from missions
- `ReviewerAgent.js` - Reviews plans for safety
- `ExecutorAgent.js` - Executes approved bash commands
- `ReflectorAgent.js` - Analyzes outcomes
- `MemoryAgent.js` - Manages long-term memory
- `SystemAgent.js` - Self-improvement proposals
- `ConversationAgent.js` - Human-agent communication

### Configuration
- `.env` - API keys and configuration
- `exec_policy.json` - Command whitelist/blacklist
- `run_steps.sh` - Bash command executor

### Web Interface
- `site/dashboard.html` - Main monitoring dashboard
- `site/dashboard.js` - Dashboard JavaScript
- `site/dashboard.css` - Dashboard styles

## 🔧 Current Configuration (.env)

```
GOOGLE_API_KEY=AIzaSyBbSkUOflQClwNcmKPmHusAuSQCluCyBss
PORT=3456
DB_PATH=./data/gaa.db
MODEL_PRO=gemini-2.0-flash-exp
MODEL_FLASH=gemini-2.0-flash-exp
AUTO_APPROVE_RISK_THRESHOLD=0.4
MAX_APPROVED_STEPS_PER_LOOP=15
SYSTEM_AGENT_INTERVAL=10
API_DELAY_MS=15000
EXECUTION_PATH=./data
```

## 📊 API Endpoints

- `GET /api/status` - System status and loop count
- `GET /api/activities` - Recent agent activities
- `GET /api/reflections` - Agent learnings
- `GET /api/messages` - Message history
- `POST /messages` - Send message to agents

## 💬 Communicating with Agents

```bash
# Send message (avoid JSON escaping issues)
cat > /tmp/msg.json << 'EOF'
{"content": "Your message here"}
EOF
curl -X POST http://localhost:3456/messages \
  -H "Content-Type: application/json" -d @/tmp/msg.json
```

## 🗂️ Data Directory Structure

```
data/
├── gaa.db           # SQLite database
├── src/             # Agent-created Python scripts
├── articles/        # Fetched article data
├── reports/         # Generated reports
├── knowledge/       # Knowledge base files
└── tools/           # Helper scripts
```

## 🔍 Monitoring Tools

### Check Agent Status
```bash
curl -s http://localhost:3456/api/status | jq .
```

### View Recent Activities
```bash
curl -s http://localhost:3456/api/activities | jq '.[0:5]'
```

### Monitor Live Output
Watch the background bash process running `npm start` for real-time agent activity.

## 🐛 Known Issues

1. **YAML Parsing** - ~30% success rate, needs improvement
2. **API Usage** - Using ~30 calls per loop (inefficient)
3. **VAR Assignment** - Agents struggle with `VAR=$(command)` syntax
4. **Message Escaping** - JSON escaping issues with direct curl

## ✅ What's Working

- Agents can execute complex bash scripts
- Good at creating documentation and reports
- SystemAgent proposes legitimate improvements
- Memory compression and storage works
- ConversationAgent handles bidirectional messaging
- Dashboard provides real-time monitoring

## 🎯 Current Mission

Agents are focused on:
1. Improving the GAA system itself
2. Better autonomous collaboration with Claude
3. Organizing existing code and files
4. Creating clear documentation

## 📝 Helper Scripts

### Wake System
- `claude_auto_wake.sh` - Send wake prompt to Claude
- `monitor_agents.sh` - Check for #TASKS markers
- `quick_wake_setup.sh` - Set up auto-wake cron

### Git Integration
- `git_setup.sh` - Configure Git credentials
- `CREATE_GITHUB_REPO.sh` - Create GitHub repository
- `PUSH_TO_GIT_NOW.sh` - Push changes to GitHub

### Backup
- `backup_schedule.sh` - Automated backup system

## 🚦 Quick Status Check

```bash
# Is it running?
ps aux | grep "node.*server.js"

# Check database
echo "SELECT COUNT(*) as loops FROM loops;" | sqlite3 data/gaa.db

# Recent files created
ls -lt data/ | head -10
```

## 📌 Important Notes

- Dashboard at http://localhost:3456/dashboard.html
- Agents work in `./data/` directory
- Mission stored in database, not in code
- Use TodoWrite tool for task tracking
- Agents should challenge Claude with ambitious requests

---
*Last Updated: August 31, 2025*
*GAA-5-Testing v5.0.0*