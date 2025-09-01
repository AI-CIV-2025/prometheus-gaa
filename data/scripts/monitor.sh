#!/bin/bash
# Basic system monitoring script

LOG_FILE="./data/system.log"
CONFIG_FILE="./data/configs/example.json"

# Ensure log file exists
touch "$LOG_FILE"

echo "--- System Monitoring ---"
echo "Timestamp: $(date)"
echo "Log file: $LOG_FILE"
echo "Config file: $CONFIG_FILE"
echo ""

echo "--- Log Summary ---"
echo "Total lines in log: $(wc -l < "$LOG_FILE")"
echo "Errors logged: $(grep -c "ERROR" "$LOG_FILE")"
echo "Warnings logged: $(grep -c "WARN" "$LOG_FILE")"
echo ""

echo "--- Configuration Status ---"
if [ -f "$CONFIG_FILE" ]; then
  echo "Config file exists."
  # Example: check a specific config value if needed, e.g., log_level
  # log_level=$(jq -r '.log_level' "$CONFIG_FILE")
  # echo "Log level from config: $log_level"
else
  echo "Config file not found."
fi
echo ""

echo "--- File System Status ---"
echo "Disk usage for $(pwd):"
df -h . | tail -1
echo ""
