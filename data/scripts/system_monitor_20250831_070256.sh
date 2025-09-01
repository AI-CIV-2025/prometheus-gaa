#!/bin/bash
echo "=== System Monitoring Report - $(date) ==="
echo ""

echo "## General System Information"
echo "Current Time: $(date)"
echo "System Uptime: $(uptime -p)"
echo "Logged in users: $(who)"
echo ""

echo "## Disk Usage Summary"
echo "Disk usage for current path (${EXECUTION_PATH:-./data}):"
df -h .
echo ""

echo "## Memory Usage"
free -h
echo ""

echo "## File Statistics in ./data/"
echo "Total files: $(ls -1 ./data/ 2>/dev/null | wc -l)"
echo "Markdown reports: $(ls -1 ./data/reports/*.md 2>/dev/null | wc -l)"
echo "Shell scripts: $(ls -1 ./data/tools/*.sh 2>/dev/null | wc -l)"
echo "Knowledge entries: $(ls -1 ./data/knowledge/*.md 2>/dev/null | wc -l)"
echo "JSON files: $(ls -1 ./data/*.json 2>/dev/null | wc -l)"
echo ""

echo "## Recently Modified Files (last 5)"
ls -lt ./data/ 2>/dev/null | head -n 6
echo ""

echo "Monitoring complete."
