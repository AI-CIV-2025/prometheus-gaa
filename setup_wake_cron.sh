#!/bin/bash

# Setup Wake Cron for Claude Code
# This sets up the most appropriate wake method based on your environment

echo "🔧 Claude Code Wake System Setup"
echo "================================"

# Check environment
echo "Detecting environment..."

# Check if in tmux
if [ -n "$TMUX" ]; then
    echo "✅ Running in tmux"
    WAKE_METHOD="tmux"
    WAKE_SCRIPT="/home/corey/projects/GAA/gaa-5-testing/tmux_claude_wake.sh"
    
elif command -v xdotool &> /dev/null && [ -n "$DISPLAY" ]; then
    echo "✅ X11 environment detected"
    WAKE_METHOD="xdotool"
    WAKE_SCRIPT="/home/corey/projects/GAA/gaa-5-testing/wake_claude_code.sh xdotool"
    
elif command -v osascript &> /dev/null; then
    echo "✅ macOS detected"
    WAKE_METHOD="osascript"
    WAKE_SCRIPT="/home/corey/projects/GAA/gaa-5-testing/wake_claude_code.sh osascript"
    
else
    echo "⚠️ No automated input method detected"
    WAKE_METHOD="manual"
fi

if [ "$WAKE_METHOD" != "manual" ]; then
    # Make scripts executable
    chmod +x /home/corey/projects/GAA/gaa-5-testing/*.sh
    
    # Add to crontab
    CRON_CMD="*/5 * * * * $WAKE_SCRIPT >> /tmp/claude_wake.log 2>&1"
    
    # Check if already in crontab
    if crontab -l 2>/dev/null | grep -q "claude_wake"; then
        echo "✅ Wake cron already configured"
    else
        (crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -
        echo "✅ Added wake cron job"
    fi
    
    echo ""
    echo "📅 Cron configured to wake Claude Code every 5 minutes"
    echo "Method: $WAKE_METHOD"
    echo "Log: /tmp/claude_wake.log"
    
else
    echo ""
    echo "❌ Cannot set up automatic wake without tmux, X11, or macOS"
    echo ""
    echo "SOLUTION: Run Claude Code in tmux:"
    echo "1. Start new tmux session: tmux new -s claude"
    echo "2. Run Claude Code in that session"
    echo "3. Detach with: Ctrl-B then D"
    echo "4. Run this setup again"
fi

echo ""
echo "📝 Manual Wake Instructions:"
echo "----------------------------"
echo "If automatic wake doesn't work, you can manually trigger by:"
echo "1. Creating a file: echo 'wake' > /tmp/claude_wake_now"
echo "2. Then checking that file periodically"
echo "3. Or setting up a watch: watch -n 300 'cat /tmp/claude_wake_now'"