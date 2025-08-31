#!/bin/bash

# Simple Claude Auto-Wake Script
# This creates a wake trigger file every 10 minutes that can be used to wake Claude

INTERVAL=${1:-600}  # Default 10 minutes, can override with first argument
WAKE_DIR="/tmp/claude_wake"
mkdir -p "$WAKE_DIR"

echo "🤖 Claude Auto-Wake Started"
echo "Will create wake triggers every $INTERVAL seconds"
echo "Wake files will be in: $WAKE_DIR"

while true; do
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    WAKE_FILE="$WAKE_DIR/wake_$TIMESTAMP.txt"
    
    # Check agent status
    STATUS=$(curl -s http://localhost:3456/api/status 2>/dev/null)
    if [ -n "$STATUS" ]; then
        LOOP=$(echo "$STATUS" | jq '.loopNumber // 0')
        RUNNING=$(echo "$STATUS" | jq '.isRunning // false')
        
        # Get recent messages
        MESSAGES=$(curl -s http://localhost:3456/api/messages 2>/dev/null | jq '.[0:3]')
        
        # Create wake file with context
        cat > "$WAKE_FILE" << EOF
[AUTO-WAKE CHECK] $(date)

AGENT STATUS:
- Loop Number: $LOOP  
- Running: $RUNNING

RECENT MESSAGES:
$MESSAGES

ACTION NEEDED:
1. Check http://localhost:3456/dashboard.html
2. Review agent messages for help requests
3. Check for stuck loops or errors
4. Send encouraging messages if progress made
5. Respond to any challenges or requests

To respond, check the dashboard and send messages as needed.
EOF
        
        echo "✅ Wake trigger created: $WAKE_FILE"
        echo "   Loop #$LOOP, Running: $RUNNING"
        
        # Optional: Create a simple prompt file for easy copy-paste
        echo "Check on GAA agents - Loop #$LOOP" > "$WAKE_DIR/latest_prompt.txt"
    else
        echo "⚠️  Cannot reach GAA server"
    fi
    
    echo "💤 Next check in $INTERVAL seconds ($(date -d "+$INTERVAL seconds" '+%H:%M' 2>/dev/null || date))"
    sleep "$INTERVAL"
done