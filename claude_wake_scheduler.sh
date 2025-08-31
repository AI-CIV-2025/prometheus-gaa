#!/bin/bash

# Claude Code Auto-Wake Scheduler for GAA-5
# Checks agent messages every 10 minutes and wakes Claude if needed

set -euo pipefail

# Configuration
CHECK_INTERVAL=${CHECK_INTERVAL:-600}  # 10 minutes in seconds
GAA_URL="http://localhost:3456"
WAKE_FILE="/tmp/claude_wake_trigger.txt"
LOG_FILE="/tmp/claude_wake_scheduler.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🤖 Claude Wake Scheduler Started${NC}"
echo "Checking every $CHECK_INTERVAL seconds for agent requests..."
echo "---" >> "$LOG_FILE"
echo "$(date): Scheduler started" >> "$LOG_FILE"

# Function to check for unread agent messages
check_agent_messages() {
    echo "$(date): Checking for agent messages..." >> "$LOG_FILE"
    
    # Get messages from API
    MESSAGES=$(curl -s "$GAA_URL/api/messages" 2>/dev/null || echo "[]")
    
    # Check for recent agent messages asking for help
    HELP_NEEDED=$(echo "$MESSAGES" | jq '[.[] | select(.source == "agent" and .content != null)] | 
        map(select(.content | test("Claude|help|assist|create|build|fix|debug|todo|task"; "i"))) | 
        length')
    
    # Get recent activities to see if agents are struggling
    ACTIVITIES=$(curl -s "$GAA_URL/api/activities?limit=20" 2>/dev/null || echo "[]")
    ERROR_COUNT=$(echo "$ACTIVITIES" | jq '[.[] | select(.level == "error")] | length')
    
    # Get current loop status
    STATUS=$(curl -s "$GAA_URL/api/status" 2>/dev/null || echo "{}")
    LOOP_NUM=$(echo "$STATUS" | jq '.loopNumber // 0')
    
    echo "$(date): Found $HELP_NEEDED help requests, $ERROR_COUNT errors, Loop #$LOOP_NUM" >> "$LOG_FILE"
    
    # Determine if we should wake Claude
    if [ "$HELP_NEEDED" -gt 0 ] || [ "$ERROR_COUNT" -gt 3 ]; then
        return 0  # Wake needed
    else
        return 1  # No wake needed
    fi
}

# Function to create wake trigger
create_wake_trigger() {
    local reason="$1"
    
    echo -e "${YELLOW}⏰ Wake trigger activated: $reason${NC}"
    echo "$(date): Creating wake trigger - $reason" >> "$LOG_FILE"
    
    # Create wake file with context
    cat > "$WAKE_FILE" << EOF
[AUTO-WAKE] Claude Code Check-In - $(date)
Reason: $reason

Please check on the GAA agents and:
1. Review recent agent messages for help requests
2. Check for any errors or stuck loops
3. Offer assistance with complex tasks
4. Send encouraging messages if they're making progress
5. Update any pending todos they've requested

Dashboard: http://localhost:3456/dashboard.html
EOF
    
    # Send a message to agents letting them know
    curl -X POST "$GAA_URL/messages" \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"[ClaudeC-AutoWake] Checking in! Reviewing your recent work and looking for ways to help. Stand by...\"}" \
        2>/dev/null || true
}

# Function to check agent status and create summary
check_agent_status() {
    local status_msg=""
    
    # Get current status
    STATUS=$(curl -s "$GAA_URL/api/status" 2>/dev/null)
    if [ -n "$STATUS" ] && [ "$STATUS" != "{}" ]; then
        LOOP=$(echo "$STATUS" | jq '.loopNumber // 0')
        RUNNING=$(echo "$STATUS" | jq '.isRunning // false')
        
        status_msg="Loop #$LOOP, Running: $RUNNING"
        
        # Check for help requests
        MESSAGES=$(curl -s "$GAA_URL/api/messages" 2>/dev/null)
        HELP_COUNT=$(echo "$MESSAGES" | jq '[.[] | select(.source == "agent" and .content != null) | 
            select(.content | test("Claude|help"; "i"))] | length')
        
        if [ "$HELP_COUNT" -gt 0 ]; then
            create_wake_trigger "Agents requesting help ($HELP_COUNT messages)"
            return 0
        fi
        
        # Check for errors in recent activities
        ACTIVITIES=$(curl -s "$GAA_URL/api/activities?limit=10" 2>/dev/null)
        ERRORS=$(echo "$ACTIVITIES" | jq '[.[] | select(.level == "error")] | length')
        
        if [ "$ERRORS" -gt 2 ]; then
            create_wake_trigger "Multiple errors detected ($ERRORS in last 10 activities)"
            return 0
        fi
        
        echo -e "${GREEN}✓ Agents operating normally - $status_msg${NC}"
    else
        echo -e "${RED}⚠ Cannot reach GAA server${NC}"
    fi
    
    return 1
}

# Main loop
while true; do
    echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - Checking agent status..."
    
    if check_agent_status; then
        echo -e "${YELLOW}📢 Wake trigger created. Check $WAKE_FILE for details${NC}"
        
        # Optional: Try to send a notification (Mac only)
        if command -v osascript &> /dev/null; then
            osascript -e 'display notification "GAA agents need assistance" with title "Claude Wake Alert"' 2>/dev/null || true
        fi
    fi
    
    echo "Next check in $CHECK_INTERVAL seconds ($(date -d "+$CHECK_INTERVAL seconds" '+%H:%M:%S' 2>/dev/null || date))"
    sleep "$CHECK_INTERVAL"
done