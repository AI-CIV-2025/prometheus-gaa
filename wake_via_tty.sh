#!/bin/bash

# Wake Claude Code via TTY
# Sends input directly to the terminal where Claude is running

echo "🔍 Finding Claude Code terminals..."

# Find Claude process and its terminal
CLAUDE_TTY=$(ps aux | grep "claude" | grep -v grep | head -1 | awk '{print $7}')

if [ -n "$CLAUDE_TTY" ] && [ "$CLAUDE_TTY" != "?" ]; then
    echo "✅ Found Claude on terminal: $CLAUDE_TTY"
    
    # Convert pts/X to /dev/pts/X
    TTY_DEVICE="/dev/$CLAUDE_TTY"
    
    if [ -w "$TTY_DEVICE" ]; then
        MESSAGE="Check GAA agents - auto wake at $(date +%H:%M)"
        
        echo "📝 Sending wake message to $TTY_DEVICE"
        echo "$MESSAGE" > "$TTY_DEVICE"
        
        echo "✅ Wake message sent!"
    else
        echo "❌ Cannot write to $TTY_DEVICE"
        echo "You may need to run: sudo chmod 666 $TTY_DEVICE"
        echo "Or run this script with appropriate permissions"
    fi
else
    echo "❌ Claude Code not found or not on a terminal"
    echo ""
    echo "Current Claude processes:"
    ps aux | grep claude | grep -v grep
fi

echo ""
echo "Alternative: Use screen or tmux for better control:"
echo "1. Start screen: screen -S claude"
echo "2. Run Claude Code inside screen"
echo "3. Detach: Ctrl-A then D"
echo "4. Send commands: screen -S claude -X stuff 'your message here^M'"