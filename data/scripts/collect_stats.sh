#!/bin/bash
# Collects and logs basic system statistics.

LOG_DIR="./data/logs"
mkdir -p "$LOG_DIR" # Create log directory if it doesn't exist

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="$LOG_DIR/system_stats_${TIMESTAMP}.log"

echo "--- System Statistics Collection ---" | tee -a "$LOG_FILE"
echo "Timestamp: $TIMESTAMP" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "### Environment ###" | tee -a "$LOG_FILE"
echo "EXECUTION_PATH: ${EXECUTION_PATH:-./data}" | tee -a "$LOG_FILE"
echo "Hostname: $(hostname)" | tee -a "$LOG_FILE"
echo "Current User: $(whoami)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "### File System ###" | tee -a "$LOG_FILE"
echo "Total files in ./data/: $(ls -1 ./data/ 2>/dev/null | wc -l)" | tee -a "$LOG_FILE"
echo "Markdown files: $(find ./data -name "*.md" 2>/dev/null | wc -l)" | tee -a "$LOG_FILE"
echo "Log files: $(find ./data -name "*.log" 2>/dev/null | wc -l)" | tee -a "$LOG_FILE"
echo "Script files: $(find ./data -name "*.sh" 2>/dev/null | wc -l)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "### System Load ###" | tee -a "$LOG_FILE"
echo "Uptime: $(uptime -p)" | tee -a "$LOG_FILE"
echo "CPU Usage (approx): $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/ \1/" | awk '{print 100 - $1"%"}')" | tee -a "$LOG_FILE"
echo "Memory Usage: $(free -h | grep Mem | awk '{print $3 "/" $2}')" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "--- Collection Complete ---" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Display the last 10 lines of the log file for immediate feedback
tail -n 10 "$LOG_FILE"
