#!/bin/bash

LOG_DIR="./data/logs"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Check disk space
DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}')
echo "[$TIMESTAMP] [INFO] Disk usage: $DISK_USAGE" >> "$LOG_DIR/system.log"

# Check memory usage (using free, requires parsing)
MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_FREE=$(free -m | awk '/^Mem:/ {print $4}')
MEM_USED=$((MEM_TOTAL - MEM_FREE))
MEM_USAGE=$(awk -v used="$MEM_USED" -v total="$MEM_TOTAL" 'BEGIN { printf "%.0f%%", (used/total)*100 }')
echo "[$TIMESTAMP] [INFO] Memory usage: $MEM_USAGE ($MEM_USED MB / $MEM_TOTAL MB)" >> "$LOG_DIR/system.log"

# Check number of running processes
PROCESS_COUNT=$(ps aux | wc -l)
echo "[$TIMESTAMP] [INFO] Running processes: $PROCESS_COUNT" >> "$LOG_DIR/system.log"

echo "System monitoring data logged."
