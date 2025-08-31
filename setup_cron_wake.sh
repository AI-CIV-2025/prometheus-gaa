#!/bin/bash

# Setup Cron Job for Claude Wake System
# This will wake Claude every 5 minutes to check on agents

echo "📅 Setting up cron job for Claude wake system..."

# Create the wake script that cron will call
cat > /home/corey/projects/GAA/gaa-5-testing/cron_wake.sh << 'EOF'
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
EOF

chmod +x /home/corey/projects/GAA/gaa-5-testing/cron_wake.sh

# Add to crontab (every 5 minutes)
CRON_CMD="/home/corey/projects/GAA/gaa-5-testing/cron_wake.sh"
CRON_JOB="*/5 * * * * $CRON_CMD"

# Check if job already exists
if crontab -l 2>/dev/null | grep -q "$CRON_CMD"; then
    echo "✅ Cron job already exists"
else
    # Add the cron job
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "✅ Cron job added successfully!"
fi

echo ""
echo "📋 Current cron jobs:"
crontab -l | grep claude || echo "(No Claude wake jobs found)"

echo ""
echo "🎯 Cron Schedule:"
echo "  - Runs every 5 minutes"
echo "  - Log file: /tmp/claude_wake_cron.log"
echo "  - To remove: crontab -e (delete the claude_wake line)"
echo "  - To view logs: tail -f /tmp/claude_wake_cron.log"