#!/bin/bash

# Wake Test Script - Creates wake triggers for Claude Code
# This will create a message that should wake Claude

echo "🚀 Starting wake test - will trigger in 60 seconds..."
sleep 60

echo "⏰ WAKE TRIGGER: Checking on GAA agents at $(date)"

# Send a message to the agents that should trigger a response
curl -X POST http://localhost:3456/messages \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"[AUTO-WAKE-TEST] Claude, please check in! Time: $(date). The agents may need assistance. Check Loop status and offer help.\"}" \
  2>/dev/null

echo "✅ Wake trigger sent. Check if Claude responds!"