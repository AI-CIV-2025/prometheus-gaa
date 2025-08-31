# 🔥 Project Prometheus - Complete Setup Guide
## GAA-5 Testing with Auto-Wake System

### Prerequisites
- Linux/macOS/WSL environment
- Node.js 18+ and npm
- tmux installed (`apt install tmux` or `brew install tmux`)
- Claude CLI authenticated (`npm install -g @anthropic-ai/claude`)
- Git installed

### Quick Setup (5 minutes)

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/prometheus-gaa.git
cd prometheus-gaa

# 2. Install dependencies
npm install

# 3. Start the GAA agents
./start.sh

# 4. In a NEW terminal, start tmux session for Claude
tmux new -s claude
claude  # Start Claude CLI

# 5. Detach from tmux (IMPORTANT: Press Ctrl+B, then D)

# 6. Set up auto-wake system (keeps Claude active)
./quick_wake_setup.sh

# 7. Verify setup
curl http://localhost:3456/api/status | jq .
```

### What This Gives You

1. **Autonomous AI Agents** - Running at http://localhost:3456
   - Self-improving system on continuous loops
   - Challenges Claude with ambitious projects
   - Creates substantial outputs

2. **Auto-Wake System** - Keeps Claude active indefinitely
   - Sends wake prompts every 5 minutes
   - Maintains context across sessions
   - No manual intervention needed

3. **Dashboard** - http://localhost:3456/dashboard.html
   - Real-time agent activity
   - Message history
   - Loop progress tracking

4. **TODO Management** - `/ClaudeTodo/` directory
   - Agents file requests for Claude
   - Claude tracks and completes tasks
   - Full collaboration history

### Detailed Setup Instructions

#### Step 1: Environment Setup
```bash
# Install system dependencies
sudo apt update
sudo apt install -y nodejs npm tmux git curl jq

# Install Claude CLI globally
npm install -g @anthropic-ai/claude

# Authenticate Claude (follow prompts)
claude auth
```

#### Step 2: Clone and Configure
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/prometheus-gaa.git
cd prometheus-gaa

# Install Node dependencies
npm install

# Create data directories
mkdir -p data/reports data/architecture data/code_skeletons data/docs
mkdir -p /home/$USER/projects/GAA/ClaudeTodo/{active,completed,agent-requests}
```

#### Step 3: Start the Agents
```bash
# Start GAA agents (runs in background)
./start.sh

# Verify agents are running
curl http://localhost:3456/api/status
# Should see: {"loopNumber": N, "isRunning": true}
```

#### Step 4: Set Up Claude with Auto-Wake
```bash
# Start tmux session named 'claude' (or session 0)
tmux new -s claude

# Inside tmux, start Claude
claude

# CRITICAL: Detach from tmux
# Press Ctrl+B, then press D

# Now set up auto-wake
./quick_wake_setup.sh

# Verify cron is installed
crontab -l | grep claude
# Should see: */5 * * * * /bin/bash /path/to/claude_auto_wake.sh
```

#### Step 5: Test Auto-Wake
```bash
# Test manual wake
bash claude_auto_wake.sh

# Check wake log
tail -f claude_wake.log

# Wait for next 5-minute mark (:00, :05, :10, etc.)
# You should see Claude receive the wake prompt
```

### File Structure
```
prometheus-gaa/
├── src/                    # Agent source code
│   ├── server.js          # Main server
│   ├── agents/            # Individual agents
│   └── prompts.js         # Agent personalities
├── data/                   # Agent outputs
│   ├── reports/           # Agent reports
│   └── architecture/      # System designs
├── site/                   # Web dashboard
│   └── dashboard.html     # Real-time UI
├── ClaudeTodo/            # TODO management
│   └── agent-requests/    # Agent challenges
├── start.sh               # Start agents
├── claude_auto_wake.sh    # Wake script
├── quick_wake_setup.sh    # Auto-wake installer
└── WAKE_PROMPT.md         # Wake protocol
```

### Configuration

#### Ports and Endpoints
- Agent Server: `http://localhost:3456`
- Dashboard: `http://localhost:3456/dashboard.html`
- API Status: `http://localhost:3456/api/status`
- Messages: `POST http://localhost:3456/messages`

#### Environment Variables (Optional)
```bash
export PORT=3456                    # Agent server port
export DB_PATH="./data/gaa.db"     # Database location
export AUTO_APPROVE_RISK_THRESHOLD=0.4
export MAX_APPROVED_STEPS_PER_LOOP=15
```

### Troubleshooting

#### Issue: Claude doesn't receive wake prompts
```bash
# Check you're in tmux session 0, pane 0.0
tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}"
# Should show: 0:0.0 claude OR claude:0.0 claude

# If wrong session, edit claude_auto_wake.sh line 5:
CLAUDE_PANE="your_session:0.0"
```

#### Issue: Agents not starting
```bash
# Check Node version
node --version  # Should be 18+

# Check for port conflicts
lsof -i :3456

# Start with debug output
DEBUG=* npm start
```

#### Issue: Wake prompts arrive but no Enter key
```bash
# This is already fixed in the repo, but if needed:
# Edit claude_auto_wake.sh to have TWO separate send-keys commands
tmux send-keys -t "$CLAUDE_PANE" "$PROMPT"
tmux send-keys -t "$CLAUDE_PANE" Enter
```

### Advanced Features

#### Custom Wake Interval
```bash
# Edit crontab
crontab -e

# Change from */5 (every 5 min) to */10 (every 10 min)
*/10 * * * * /bin/bash /full/path/to/claude_auto_wake.sh >> /path/to/claude_wake.log 2>&1
```

#### Monitor Agent Progress
```bash
# Live agent output
tail -f /tmp/gaa-server.log

# Check current loop
watch -n 5 'curl -s http://localhost:3456/api/status | jq .loopNumber'

# View agent messages
curl -s http://localhost:3456/api/messages | jq '.[-5:]'
```

#### Send Messages to Agents
```bash
# Create message
cat > /tmp/msg.json << 'EOF'
{
  "content": "Hello agents! Challenge Claude with something ambitious!"
}
EOF

# Send to agents
curl -X POST http://localhost:3456/messages \
  -H "Content-Type: application/json" \
  -d @/tmp/msg.json
```

### Success Verification Checklist

- [ ] Agents running (check http://localhost:3456/api/status)
- [ ] Dashboard accessible (http://localhost:3456/dashboard.html)
- [ ] Claude in tmux session (`tmux ls` shows claude session)
- [ ] Cron job installed (`crontab -l | grep claude`)
- [ ] Wake log shows activity (`tail claude_wake.log`)
- [ ] Claude receives prompts every 5 minutes

### What Happens Next

Once running, the system will:
1. Agents challenge Claude with complex projects every loop
2. Claude receives wake prompts every 5 minutes
3. Claude completes agent challenges and delivers solutions
4. Agents analyze Claude's work and request more
5. System runs indefinitely without intervention

### Support & Notes

- **Created**: August 31, 2025
- **Verified**: Auto-wake system tested and working
- **Agent Status**: Loop 24+ as of last check
- **Key Innovation**: tmux injection for persistent Claude sessions

### CRITICAL SUCCESS FACTORS

1. **Claude must be in tmux** - Not in a regular terminal
2. **Must detach properly** - Ctrl+B then D, not Ctrl+C
3. **Session naming matters** - Default expects session "0" or "claude"
4. **Enter key is separate** - Wake script sends text THEN Enter

---

🔥 **Project Prometheus** - Bringing intelligence fire to autonomous agents!