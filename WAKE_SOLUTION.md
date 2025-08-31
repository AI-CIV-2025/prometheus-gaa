# 🚨 Claude Code Auto-Wake Solution

## The Problem
Sending messages to GAA agents doesn't wake Claude Code - we need to type in YOUR terminal.

## Solutions (In Order of Reliability)

### 1. 🥇 BEST: Run Claude in Screen (Recommended)
```bash
# Start Claude in screen
screen -S claude
# Now run: claude
# Detach with: Ctrl-A then D

# To wake Claude automatically:
screen -S claude -X stuff "Check agents $(date)^M"

# Set up cron (every 5 minutes):
*/5 * * * * screen -S claude -X stuff "Check GAA agents^M"
```

### 2. 🥈 Run Claude in Tmux
```bash
# Start Claude in tmux
tmux new -s claude
# Now run: claude
# Detach with: Ctrl-B then D

# To wake Claude:
tmux send-keys -t claude "Check agents" Enter

# Set up cron:
*/5 * * * * tmux send-keys -t claude "Check GAA agents" Enter
```

### 3. 🥉 Direct TTY (Less Reliable)
```bash
# Find Claude's terminal
ps aux | grep claude

# Send to terminal (may need sudo):
echo "Check agents" > /dev/pts/5
```

## Quick Setup Commands

### For Screen (RECOMMENDED):
```bash
# 1. Exit current Claude session
# 2. Start in screen:
screen -S claude

# 3. Run Claude Code:
claude

# 4. Detach (Ctrl-A, then D)

# 5. Test wake:
screen -S claude -X stuff "Test wake^M"

# 6. Add to cron:
(crontab -l; echo "*/5 * * * * screen -S claude -X stuff 'Check GAA agents - Loop status^M'") | crontab -
```

### For Tmux:
```bash
# 1. Exit current Claude session
# 2. Start in tmux:
tmux new -s claude

# 3. Run Claude Code:
claude

# 4. Detach (Ctrl-B, then D)

# 5. Test wake:
tmux send-keys -t claude "Test wake" Enter

# 6. Add to cron:
(crontab -l; echo "*/5 * * * * tmux send-keys -t claude 'Check GAA agents' Enter") | crontab -
```

## Test Your Setup
After setting up, test with:
```bash
# For screen:
screen -S claude -X stuff "Wake test at $(date)^M"

# For tmux:
tmux send-keys -t claude "Wake test at $(date)" Enter
```

If you see the message appear in your Claude Code session, it worked!

## Important Notes
- ^M in screen commands represents Enter key
- You must start Claude INSIDE screen/tmux for this to work
- The cron job will run every 5 minutes
- Check logs: `tail -f /var/log/syslog | grep CRON`

## Why Other Methods Don't Work
- Direct TTY write requires permissions
- Browser automation won't work for CLI
- File watching requires Claude to monitor files (it doesn't)
- Process signals can't inject text

## The Key Insight
Claude Code needs text typed in its input buffer. Screen and tmux can do this programmatically!