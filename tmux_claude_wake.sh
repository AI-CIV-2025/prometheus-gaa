#!/bin/bash

# TMUX-based Claude Code Wake System
# This finds your Claude Code session and sends input directly to it

echo "🔍 Searching for Claude Code session in tmux..."

# Method 1: Look for pane running 'claude' command
CLAUDE_PANE=$(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}" 2>/dev/null | grep claude | cut -d' ' -f1 | head -1)

# Method 2: Look for session with 'claude' in name
if [ -z "$CLAUDE_PANE" ]; then
    CLAUDE_SESSION=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -i claude | head -1)
    if [ -n "$CLAUDE_SESSION" ]; then
        CLAUDE_PANE="${CLAUDE_SESSION}:0.0"
    fi
fi

# Method 3: Look for window with 'claude' in name
if [ -z "$CLAUDE_PANE" ]; then
    CLAUDE_WINDOW=$(tmux list-windows -a -F "#{session_name}:#{window_index} #{window_name}" 2>/dev/null | grep -i claude | cut -d' ' -f1 | head -1)
    if [ -n "$CLAUDE_WINDOW" ]; then
        CLAUDE_PANE="${CLAUDE_WINDOW}.0"
    fi
fi

if [ -n "$CLAUDE_PANE" ]; then
    echo "✅ Found Claude Code in pane: $CLAUDE_PANE"
    
    # Check agent status first
    STATUS=$(curl -s http://localhost:3456/api/status 2>/dev/null)
    if [ -n "$STATUS" ]; then
        LOOP=$(echo "$STATUS" | jq '.loopNumber // 0')
        RUNNING=$(echo "$STATUS" | jq '.isRunning // false')
        
        # Check for recent errors
        ERRORS=$(curl -s http://localhost:3456/api/activities?limit=10 2>/dev/null | jq '[.[] | select(.level == "error")] | length')
        
        MESSAGE="Check GAA agents - Loop #$LOOP, Running: $RUNNING"
        
        if [ "$ERRORS" -gt 0 ]; then
            MESSAGE="$MESSAGE, Errors: $ERRORS - agents may need help!"
        fi
    else
        MESSAGE="Check on GAA agents - server may be down"
    fi
    
    echo "📝 Sending wake message: $MESSAGE"
    
    # Send the message to Claude Code
    tmux send-keys -t "$CLAUDE_PANE" "$MESSAGE" Enter
    
    echo "✅ Wake message sent!"
    echo ""
    echo "To set up automatic waking every 5 minutes, add to crontab:"
    echo "*/5 * * * * /home/corey/projects/GAA/gaa-5-testing/tmux_claude_wake.sh"
    
else
    echo "❌ Could not find Claude Code session in tmux"
    echo ""
    echo "Make sure Claude Code is running in tmux. Try one of these:"
    echo "1. Start Claude in tmux: tmux new -s claude 'claude'"
    echo "2. Rename your current tmux session: tmux rename-session claude"
    echo "3. Rename your current window: tmux rename-window claude"
    echo ""
    echo "Current tmux sessions:"
    tmux list-sessions 2>/dev/null || echo "(No tmux sessions found)"
fi