#!/bin/bash

LOG_FILE="./data/logs/monitor_$(date +%Y%m%d_%H%M%S).log"

echo "--- System Monitoring Report ---" | tee -a "$LOG_FILE"
echo "Timestamp: $(date)" | tee -a "$LOG_FILE"
echo "--------------------------------" | tee -a "$LOG_FILE"

echo -e "\n### CPU & Uptime ###" | tee -a "$LOG_FILE"
uptime | tee -a "$LOG_FILE"

echo -e "\n### Memory Usage ###" | tee -a "$LOG_FILE"
free -h | tee -a "$LOG_FILE"

echo -e "\n### Disk Usage (./data) ###" | tee -a "$LOG_FILE"
df -h . | tee -a "$LOG_FILE"

echo -e "\n### Running Processes Count ###" | tee -a "$LOG_FILE"
ps -ef | wc -l | tee -a "$LOG_FILE"

echo -e "\n### Network Connections (LISTEN/ESTABLISHED) ###" | tee -a "$LOG_FILE"
ss -tuna | grep -E 'LISTEN|ESTAB' | wc -l | tee -a "$LOG_FILE"

echo -e "\n### Recently Modified Files in ./data (Last 5) ###" | tee -a "$LOG_FILE"
ls -lt ./data/ | head -n 6 | tee -a "$LOG_FILE"

echo -e "\n--- End of Report ---" | tee -a "$LOG_FILE"
echo "Monitoring data logged to: $LOG_FILE"
