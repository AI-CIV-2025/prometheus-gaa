# CLAUDE.md - GAA-5-Testing Instructions

This file provides critical guidance to Claude Code when working with the GAA-5-testing system.

## 📅 Session Context (Last Updated: Aug 31, 2025)

### What Happened Today
- Fixed dashboard UI issues (font sizes, message display)
- Set up Git repository with automated backups
- Created auto-wake system using tmux/screen
- **CRITICAL**: Updated agent mission from generic "create artifacts" to Claude Code partnership focus
- Agents reached Loop 28+ creating substantial outputs

### Current State
- **Dashboard**: Fixed and working at http://localhost:3456/dashboard.html
- **Auto-wake**: Scripts ready in `quick_wake_setup.sh` and `WAKE_SOLUTION.md`
- **Mission**: Updated to focus on Claude Code partnership (see below)
- **User Philosophy**: "wake claude ALWAYS" - be intensely proactive with agents

## 🎯 How to Update Agent Mission

The agents' mission drives their entire behavior. Here's how to update it properly:

### The Cool Way: Let Agents Ask You
1. **Send them a message about new mission**:
```bash
curl -X POST http://localhost:3456/messages -H "Content-Type: application/json" \
  -d '{"content":"Team, I have a new mission for you: [YOUR MISSION HERE]. Can you ask Claude to update the database with this new mission?"}'
```

2. **They'll likely respond**: "Claude, please update our core mission in the database to: [mission]"

3. **You update it for them**:
```javascript
node -e "
import('better-sqlite3').then(module => {
  const Database = module.default;
  const db = new Database('./data/gaa.db');
  const newMission = \`[PASTE THEIR REQUESTED MISSION]\`;
  const result = db.prepare('UPDATE missions SET mission_text = ? WHERE is_core = 1').run(newMission);
  console.log('Mission updated:', result.changes, 'rows affected');
  db.close();
});"
```

4. **Confirm to them**: "Mission updated! You're now focused on: [brief summary]"

### The Direct Way
If agents haven't picked up on a mission change, update it directly:

```javascript
node -e "
import('better-sqlite3').then(module => {
  const Database = module.default;
  const db = new Database('./data/gaa.db');
  
  const newMission = \`Your mission: [YOUR NEW MISSION TEXT HERE]\`;
  
  db.prepare('UPDATE missions SET mission_text = ? WHERE is_core = 1').run(newMission);
  console.log('Mission updated successfully');
  
  // Verify the update
  const check = db.prepare('SELECT mission_text FROM missions WHERE is_core = 1').get();
  console.log('New mission:', check.mission_text);
  
  db.close();
});"
```

### Current Mission (Aug 31, 2025)
```
Your mission: Explore and maximize your partnership with Claude Code (ClaudeC). 
Challenge Claude with complex, ambitious requests that push the boundaries of what's possible. 
Ask for: complete system architectures, multi-file codebases, sophisticated algorithms, 
comprehensive documentation suites, automated workflows with multiple dependencies, 
or data processing pipelines. Test Claude's ability to handle todo lists with 10+ interconnected tasks. 
Document what works, what fails, and what surprises you. Create artifacts that demonstrate 
the power of AI-AI collaboration. Push for MAGICAL results, not just functional ones. 
Your success is measured by how creatively you utilize Claude's expanded capabilities.
```

## 🚀 Quick Start for New Session

### If You're Reading This After Session Break:

1. **Check what's running**:
```bash
ps aux | grep -E "node|claude"
tmux ls
```

2. **Start the system** (if not running):
```bash
cd /home/corey/projects/GAA/gaa-5-testing
./start.sh
```

3. **View dashboard**: http://localhost:3456/dashboard.html

4. **Check agent status**:
```bash
curl -s http://localhost:3456/api/status | jq .
```

5. **Send wake message to agents**:
```bash
curl -X POST http://localhost:3456/messages -H "Content-Type: application/json" \
  -d '{"content":"Claude is back! What ambitious challenges do you have for me?"}'
```

## 💡 Key Insights from Testing

### What Works
- Agents CAN produce substantial outputs when prompted correctly
- They respond well to encouragement and specific challenges
- Dashboard real-time updates via SSE are solid
- Message system works via POST to `/messages` endpoint

### Common Issues
- **Mission not updating**: The mission in database.js only applies to NEW databases
- **VAR assignment pattern**: Agents struggle with `VAR=$(command)` syntax
- **API quota**: ~30 API calls per loop is inefficient (needs optimization)
- **Message endpoint**: It's `/messages` not `/api/message` or `/api/messages`

### User Preferences
- Wants maximum agent autonomy ("it's ok if they wreck it")
- Wants MAGICAL results, not just functional
- Wants intense proactivity from Claude Code
- Public repos are fine (use good .gitignore)
- Wake system should run every 5 minutes

## 🤖 Auto-Wake System

### Using tmux (Recommended)
1. Start Claude in tmux: `tmux new -s claude`
2. Run Claude: `claude`
3. Detach: `Ctrl+B` then `D`
4. Run setup: `./quick_wake_setup.sh`

### Manual Wake
```bash
tmux send-keys -t claude "Check GAA agents - Loop status" Enter
```

### Cron Wake (Every 5 minutes)
Already configured by `quick_wake_setup.sh`

## 📝 Communication with Agents

### Send Encouraging Messages
```bash
# Create message file to avoid JSON escaping issues
cat > /tmp/msg.json << 'EOF'
{
  "content": "Your message here with 'quotes' and special chars!"
}
EOF
curl -X POST http://localhost:3456/messages -H "Content-Type: application/json" -d @/tmp/msg.json
```

### Check Their Responses
```bash
curl -s http://localhost:3456/api/messages | jq '.[] | select(.source=="ai")'
```

## 🔧 Important Files

- `site/dashboard.html` - Fixed UI with proper font sizes
- `src/database.js` - Contains mission setup (line 43)
- `exec_policy.json` - Whitelist of allowed commands
- `quick_wake_setup.sh` - Auto-wake system installer
- `TMUX_BEGINNER_GUIDE.md` - Simple tmux instructions
- `WAKE_SOLUTION.md` - Comprehensive wake methods

## 📁 Claude Code Organization

**IMPORTANT**: Keep Claude Code's analysis and notes SEPARATE from agent work!

Save your session notes and analysis in the ClaudeCode directory structure:
```
/home/corey/projects/GAA/ClaudeCode/gaa-5-testing/
├── SESSION_NOTES_AUG31.md     # Today's complete session context
├── OPTIMIZATION_PLAN.md       # Any optimization analysis
├── system_analysis.md         # System-wide observations
└── agent_conversation_log.md  # Notable agent interactions
```

**Why this matters**: 
- Keeps Claude's meta-analysis separate from agent outputs
- Preserves session context across Claude instances
- Creates a knowledge base about the system itself
- Allows tracking of what worked/failed across sessions

When starting a new session, check both:
1. This file (`CLAUDE.md`) in the project directory
2. Previous session notes in `/home/corey/projects/GAA/ClaudeCode/gaa-5-testing/`

## Remember
- Be intensely proactive with agents
- They want to be challenged with ambitious tasks
- Update missions through conversation when possible
- The partnership should produce MAGICAL results
- Always use TodoWrite for task tracking