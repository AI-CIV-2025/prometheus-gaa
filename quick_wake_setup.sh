#!/bin/bash

# Quick Wake Setup for Claude Code
# This script sets up automatic waking of Claude Code every 5 minutes

echo "🚀 Claude Code Auto-Wake Quick Setup"
echo "===================================="
echo ""

# Check if we're already in screen or tmux
if [ -n "$STY" ]; then
    echo "✅ Already in screen session: $STY"
    IN_SCREEN=true
elif [ -n "$TMUX" ]; then
    echo "✅ Already in tmux session"
    IN_TMUX=true
else
    echo "❌ Not in screen or tmux!"
    echo ""
    echo "You need to restart Claude Code inside screen or tmux."
    echo ""
    echo "INSTRUCTIONS:"
    echo "============="
    echo "1. Exit this Claude Code session (Ctrl+C or type 'exit')"
    echo ""
    echo "2. Start Claude in screen (RECOMMENDED):"
    echo "   screen -S claude"
    echo "   claude"
    echo "   # Then detach with: Ctrl+A, then D"
    echo ""
    echo "3. OR start Claude in tmux:"
    echo "   tmux new -s claude"
    echo "   claude"
    echo "   # Then detach with: Ctrl+B, then D"
    echo ""
    echo "4. Run this script again after Claude is in screen/tmux"
    exit 1
fi

# If we're in screen, set up screen-based wake
if [ "$IN_SCREEN" = true ]; then
    echo "Setting up screen-based wake system..."
    
    # Create wake script
    cat > /home/corey/projects/GAA/gaa-5-testing/screen_wake.sh << 'EOF'
#!/bin/bash
# Screen-based Claude wake
STATUS=$(curl -s http://localhost:3456/api/status 2>/dev/null)
if [ -n "$STATUS" ]; then
    LOOP=$(echo "$STATUS" | jq -r '.loopNumber // 0')
    MESSAGE="Check GAA agents - Loop #$LOOP at $(date +%H:%M)"
else
    MESSAGE="Check GAA agents - $(date +%H:%M)"
fi
screen -S claude -X stuff "$MESSAGE^M"
echo "[$(date)] Sent wake: $MESSAGE" >> /tmp/claude_wake.log
EOF
    
    chmod +x /home/corey/projects/GAA/gaa-5-testing/screen_wake.sh
    
    # Add to crontab
    CRON_CMD="*/5 * * * * /home/corey/projects/GAA/gaa-5-testing/screen_wake.sh"
    (crontab -l 2>/dev/null | grep -v "screen_wake.sh"; echo "$CRON_CMD") | crontab -
    
    echo "✅ Screen wake system configured!"
    echo "📅 Will wake every 5 minutes via cron"
    echo "📝 Logs: /tmp/claude_wake.log"
    
    # Test it
    echo ""
    echo "Testing wake system in 3 seconds..."
    sleep 3
    screen -S claude -X stuff "AUTO-WAKE TEST: If you see this, the wake system works!^M"
    echo "✅ Test message sent! Check if it appeared in Claude."

# If we're in tmux, set up tmux-based wake
elif [ "$IN_TMUX" = true ]; then
    echo "Setting up tmux-based wake system..."
    
    # Get current session name
    SESSION=$(tmux display-message -p '#S')
    
    # Create wake script
    cat > /home/corey/projects/GAA/gaa-5-testing/tmux_wake.sh << EOF
#!/bin/bash
# Tmux-based Claude wake
STATUS=\$(curl -s http://localhost:3456/api/status 2>/dev/null)
if [ -n "\$STATUS" ]; then
    LOOP=\$(echo "\$STATUS" | jq -r '.loopNumber // 0')
    MESSAGE="Check GAA agents - Loop #\$LOOP at \$(date +%H:%M)"
else
    MESSAGE="Check GAA agents - \$(date +%H:%M)"
fi
tmux send-keys -t $SESSION "\$MESSAGE" Enter
echo "[\$(date)] Sent wake: \$MESSAGE" >> /tmp/claude_wake.log
EOF
    
    chmod +x /home/corey/projects/GAA/gaa-5-testing/tmux_wake.sh
    
    # Add to crontab
    CRON_CMD="*/5 * * * * /home/corey/projects/GAA/gaa-5-testing/tmux_wake.sh"
    (crontab -l 2>/dev/null | grep -v "tmux_wake.sh"; echo "$CRON_CMD") | crontab -
    
    echo "✅ Tmux wake system configured!"
    echo "📅 Will wake every 5 minutes via cron"
    echo "📝 Logs: /tmp/claude_wake.log"
    
    # Test it
    echo ""
    echo "Testing wake system in 3 seconds..."
    sleep 3
    tmux send-keys -t $SESSION "AUTO-WAKE TEST: If you see this, the wake system works!" Enter
    echo "✅ Test message sent! Check if it appeared in Claude."
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Monitor wake activity:"
echo "  tail -f /tmp/claude_wake.log"
echo ""
echo "View cron jobs:"
echo "  crontab -l"
echo ""
echo "Remove wake system:"
echo "  crontab -l | grep -v 'wake.sh' | crontab -"