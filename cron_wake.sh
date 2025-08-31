#!/bin/bash
# Cron Wake Script - Runs every 5 minutes

LOG_FILE="/tmp/claude_wake_cron.log"
echo "$(date): Cron wake triggered" >> "$LOG_FILE"

# Check if GAA is running
if curl -s http://localhost:3456/api/status > /dev/null 2>&1; then
    STATUS=$(curl -s http://localhost:3456/api/status)
    LOOP=$(echo "$STATUS" | jq '.loopNumber // 0')
    
    # Create a wake message
    echo "[CRON-WAKE] $(date) - Loop #$LOOP - Checking agent status" >> "$LOG_FILE"
    
    # Send wake message to trigger Claude check-in
    curl -X POST http://localhost:3456/messages \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"[CRON-WAKE] Scheduled check at $(date). Loop #$LOOP. Claude, please review agent status and offer assistance if needed.\"}" \
        2>/dev/null
else
    echo "$(date): GAA server not responding" >> "$LOG_FILE"
fi
