#!/bin/bash
# System Health Monitor Script

echo "=== System Health Report ==="
echo "Generated at: $(date)"
echo ""

echo "--- Disk Usage ---"
df -h / | tail -n +2
echo ""

echo "--- Memory Usage ---"
free -h
echo ""

echo "--- Running Processes (Top 5 CPU) ---"
ps aux --sort=-%cpu | head -n 6
echo ""

echo "--- Recent Log Entries (Last 10) ---"
if [ -d ./data ]; then
    find ./data -name "*.log" -type f -print0 | xargs -0 tail -n 5
else
    echo "No log files found in ./data/"
fi
echo ""
echo "=========================="
