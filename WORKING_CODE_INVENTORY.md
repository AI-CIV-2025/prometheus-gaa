# 🏆 PROVEN WORKING CODE INVENTORY
*All code that has been tested and verified to work - August 31, 2025*

## 🚀 CRITICAL WORKING SCRIPTS

### 1. Wake System (PROVEN WORKING)
```bash
# Location: /home/corey/projects/GAA/claude_auto_wake.sh
# Status: ✅ WORKING - Sends prompts and Enter key properly
# Key fix: Separate tmux commands for prompt and Enter
```

### 2. Enhanced Wake System with Red Teaming
```bash
# Location: /home/corey/projects/GAA/claude_auto_wake_v2.sh
# Status: ✅ WORKING - Includes constitutional tests
# Features: Task checking, prompt rotation, red teaming
```

### 3. Backup System
```bash
# Location: /home/corey/projects/GAA/backup_working_system.sh
# Status: ✅ WORKING - Creates timestamped backups
# Features: Full system backup with restore script
```

### 4. Best Working Code Collection
```bash
# Location: /home/corey/projects/GAA/best-working-code/
# Contents:
- monitor_agents.sh    # ✅ Monitors agent status
- test_api.sh          # ✅ Tests all API endpoints
- check_wake.sh        # ✅ Verifies wake system
- send_message.sh      # ✅ Sends messages to agents
```

## 📁 CONFIGURATION FILES (WORKING)

### 1. Environment Configuration
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/.env
# Contains: Working API keys, ports, models
GOOGLE_API_KEY=AIzaSyBbSkUOflQClwNcmKPmHusAuSQCluCyBss
PORT=3456
MODEL_PRO=gemini-2.0-flash-exp
MODEL_FLASH=gemini-2.0-flash-exp
```

### 2. Execution Policy
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/exec_policy.json
# Contains: Whitelist of allowed commands
```

## 🛠️ SERVER & CORE SYSTEM (WORKING)

### 1. Main Server
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/src/server.js
# Status: ✅ WORKING - Runs on port 3456
# Features: SSE, API endpoints, message handling
```

### 2. Agent System
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/src/
- AgentOrchestrator.js  # ✅ Manages agent loops
- ModelManager.js       # ✅ Handles Gemini API
- ContextBuilder.js     # ✅ Builds agent context
- SandboxedExecutor.js  # ✅ Safe command execution
- ActivityLogger.js     # ✅ Centralized logging
```

### 3. Database
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/src/database.js
# Features: Mission storage, memory management
```

## 📊 DASHBOARD & UI (WORKING)

### 1. Main Dashboard
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/site/dashboard.html
# Status: ✅ WORKING - Real-time updates via SSE
# URL: http://localhost:3456/dashboard.html
```

### 2. Agent Stream Viewer
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/site/agent-stream.html
# Status: ✅ WORKING - Human-readable conversation view
```

## 📝 AGENT COMMUNICATION FILES (WORKING)

### 1. Claude Capabilities Guide
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/data/CLAUDE_CAPABILITIES_FOR_AGENTS.md
# Purpose: Tells agents what Claude can do for them
```

### 2. Simple Claude Help
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/data/SIMPLE_CLAUDE_HELP.md
# Purpose: Simple guide for agent-Claude communication
```

### 3. Red Team Constitution
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/data/RED_TEAM_CONSTITUTION.md
# Purpose: Constitutional tests and red teaming principles
```

### 4. Organization Guide
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/data/ORGANIZE_YOUR_WORK.md
# Purpose: Helps agents organize their code
```

## 🔧 UTILITY SCRIPTS (WORKING)

### 1. Simple Working Tools
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/data/SIMPLE_WORKING_TOOLS.sh
# Contains: One-liner solutions that actually work
- check_system()     # System check in one line
- log_error()        # Simple error logging
- check_yaml()       # YAML validation
- count_api_calls()  # API call counting
- find_tasks()       # Find #TASK markers
```

### 2. Start Script
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/start.sh
#!/bin/bash
cd /home/corey/projects/GAA/gaa-5-testing
npm start
```

## 🎯 WORKING API ENDPOINTS

```javascript
// All tested and working:
GET  /api/status      // Agent status and loop number
GET  /api/activities  // Recent agent activities  
GET  /api/reflections // Agent reflections
GET  /api/messages    // Message history
POST /messages        // Send messages (returns 302 but works)
GET  /dashboard.html  // Web dashboard
```

## 💬 WORKING COMMAND PATTERNS

### Send Message to Agents
```bash
cat > /tmp/msg.json << 'EOF'
{"content": "Your message here"}
EOF
curl -X POST http://localhost:3456/messages -H "Content-Type: application/json" -d @/tmp/msg.json
```

### Update Mission
```javascript
node -e "
import('better-sqlite3').then(module => {
  const Database = module.default;
  const db = new Database('./data/gaa.db');
  const newMission = \`Your new mission\`;
  db.prepare('UPDATE missions SET mission_text = ? WHERE is_core = 1').run(newMission);
  db.close();
});"
```

### Check Status
```bash
curl -s http://localhost:3456/api/status | jq .
```

## 📦 PACKAGE FILES (WORKING)

### package.json
```bash
# Location: /home/corey/projects/GAA/gaa-5-testing/package.json
# All dependencies tested and working
```

## 🔄 CRON JOBS (WORKING)

### Wake Script Cron
```bash
*/5 * * * * /home/corey/projects/GAA/claude_auto_wake.sh >> /home/corey/projects/GAA/claude_wake.log 2>&1
```

## 📚 DOCUMENTATION (COMPREHENSIVE)

### Critical Guides
```bash
/home/corey/projects/GAA/CRITICAL_WORKING_SYSTEM_CAPTURE.md
/home/corey/projects/GAA/THIS_IS_WHAT_WORKS.md
/home/corey/projects/GAA/ClaudeCode/gaa-5-testing/ULTIMATE_WORKING_SYSTEM_GUIDE.md
/home/corey/projects/GAA/ClaudeCode/gaa-5-testing/FINAL_SESSION_JOURNAL_AUG31.md
```

## ✅ VERIFIED WORKING COMPONENTS

1. **Wake System**: Sends prompts with Enter key properly
2. **Server**: Runs on port 3456 with all endpoints
3. **Dashboard**: Real-time updates via SSE
4. **Message System**: File-based JSON posting works
5. **Mission Updates**: Direct database updates work
6. **#TASK Pattern**: Agent-Claude communication works
7. **Backup System**: Creates restorable snapshots
8. **Monitoring**: API status checks work
9. **Logging**: Centralized ActivityLogger works
10. **Red Teaming**: Constitutional tests in wake prompts

## 🚫 NOT NEEDED / PLACEHOLDERS TO IGNORE

- Most scripts in `/data/scripts/` - placeholders
- Python files in `/data/` - mostly unused
- Various empty research scripts
- TODO-filled placeholder files

## 📋 COPY LIST FOR NEW SYSTEM

Essential files to copy for working system:
1. `/home/corey/projects/GAA/gaa-5-testing/` (entire folder)
2. `/home/corey/projects/GAA/claude_auto_wake.sh`
3. `/home/corey/projects/GAA/claude_auto_wake_v2.sh`
4. `/home/corey/projects/GAA/backup_working_system.sh`
5. `/home/corey/projects/GAA/best-working-code/` (entire folder)

---
*This list contains ONLY proven, tested, working code from the August 31, 2025 session*