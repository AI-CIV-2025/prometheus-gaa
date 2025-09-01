#!/bin/bash
echo "=== GAA System Health Check ==="
echo "Timestamp: $(date)"
echo ""

echo "--- Disk Usage ---"
df -h / | grep '/'
echo ""

echo "--- Memory Usage ---"
free -h
echo ""

echo "--- Running Processes (Top 5 CPU intensive) ---"
ps aux --sort=-%cpu | head -n 6
echo ""

echo "--- Open Files (Top 5) ---"
lsof | awk '{ print $1 " " $4 " " $9 }' | sort | uniq -c | sort -nr | head -n 5
echo ""

echo "Health check finished."
