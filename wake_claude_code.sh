#!/bin/bash

# Wake Claude Code - Multiple Methods
# This script tries different methods to wake Claude Code

echo "🤖 Attempting to wake Claude Code..."

METHOD=${1:-tmux}
MESSAGE=${2:-"[AUTO-WAKE] Checking on GAA agents - $(date)"}

case $METHOD in
    tmux)
        # Method 1: If Claude Code is running in tmux
        echo "Trying tmux method..."
        
        # Look for claude session/pane
        CLAUDE_PANE=$(tmux list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} #{pane_current_command}" | grep -i claude | cut -d' ' -f1 | head -1)
        
        if [ -n "$CLAUDE_PANE" ]; then
            echo "Found Claude pane: $CLAUDE_PANE"
            tmux send-keys -t "$CLAUDE_PANE" "$MESSAGE" Enter
            echo "✅ Sent wake message via tmux"
        else
            echo "❌ No Claude tmux pane found"
            echo "If Claude Code is in tmux, run: tmux rename-window claude"
        fi
        ;;
        
    expect)
        # Method 2: Using expect to automate terminal
        echo "Trying expect method..."
        
        if command -v expect &> /dev/null; then
            expect << EOF
spawn bash -c "echo '$MESSAGE'"
expect eof
EOF
            echo "✅ Sent via expect"
        else
            echo "❌ expect not installed. Install with: apt-get install expect"
        fi
        ;;
        
    xdotool)
        # Method 3: X11 keyboard simulation (Linux with GUI)
        echo "Trying xdotool method..."
        
        if command -v xdotool &> /dev/null; then
            # Find Claude window
            WINDOW_ID=$(xdotool search --name "claude" | head -1)
            
            if [ -n "$WINDOW_ID" ]; then
                xdotool windowactivate "$WINDOW_ID"
                sleep 0.5
                xdotool type "$MESSAGE"
                xdotool key Return
                echo "✅ Sent via xdotool"
            else
                echo "❌ No Claude window found"
            fi
        else
            echo "❌ xdotool not installed. Install with: apt-get install xdotool"
        fi
        ;;
        
    osascript)
        # Method 4: macOS AppleScript
        echo "Trying osascript method (macOS)..."
        
        if command -v osascript &> /dev/null; then
            osascript << EOF
tell application "Terminal"
    activate
    delay 0.5
    tell application "System Events"
        keystroke "$MESSAGE"
        key code 36  # Enter key
    end tell
end tell
EOF
            echo "✅ Sent via osascript"
        else
            echo "❌ Not on macOS or osascript not available"
        fi
        ;;
        
    file)
        # Method 5: File-based trigger (if Claude monitors files)
        echo "Creating file trigger..."
        TRIGGER_FILE="/tmp/claude_wake_trigger.txt"
        echo "$MESSAGE" > "$TRIGGER_FILE"
        echo "✅ Created trigger file: $TRIGGER_FILE"
        echo "If Claude Code monitors this file, it should wake up"
        ;;
        
    *)
        echo "Usage: $0 [method] [message]"
        echo "Methods: tmux, expect, xdotool, osascript, file"
        echo ""
        echo "Examples:"
        echo "  $0 tmux 'Check agents please'"
        echo "  $0 xdotool 'Wake up Claude'"
        echo "  $0 file 'Trigger from file'"
        ;;
esac

echo ""
echo "💡 TIP: The most reliable method depends on how you're running Claude Code:"
echo "  - In tmux: Use 'tmux' method"
echo "  - In regular terminal: Use 'expect' method"  
echo "  - On Linux desktop: Use 'xdotool' method"
echo "  - On macOS: Use 'osascript' method"