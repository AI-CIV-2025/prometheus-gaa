#!/bin/bash
echo "=== AI Collaboration System Statistics ==="
echo "Generated on: $(date)"
echo ""

echo "--- File System Overview ---"
echo "Total files in ./data/: $(ls -1 ./data/ 2>/dev/null | wc -l)"
echo "  - Log files (*.log): $(ls -1 ./data/*.log 2>/dev/null | wc -l)"
echo "  - JSON files (*.json): $(ls -1 ./data/*.json 2>/dev/null | wc -l)"
echo "  - Markdown files (*.md): $(ls -1 ./data/*.md 2>/dev/null | wc -l)"
echo "  - Python scripts (*.py): $(ls -1 ./data/*.py 2>/dev/null | wc -l)"
echo "  - Shell scripts (*.sh): $(ls -1 ./data/*.sh 2>/dev/null | wc -l)"
echo "  - Node.js scripts (*.js): $(ls -1 ./data/*.js 2>/dev/null | wc -l)"
echo ""

echo "--- Task Management Status ---"
if [[ -f ./data/tasks.json ]]; then
    TOTAL_TASKS=$(jq 'length' ./data/tasks.json)
    PENDING_TASKS=$(jq '[.[] | select(.status == "pending")] | length' ./data/tasks.json)
    IN_PROGRESS_TASKS=$(jq '[.[] | select(.status == "in_progress")] | length' ./data/tasks.json)
    COMPLETED_TASKS=$(jq '[.[] | select(.status == "completed")] | length' ./data/tasks.json)
    FAILED_TASKS=$(jq '[.[] | select(.status == "failed")] | length' ./data/tasks.json)
    echo "Total tasks: $TOTAL_TASKS"
    echo "  - Pending: $PENDING_TASKS"
    echo "  - In Progress: $IN_PROGRESS_TASKS"
    echo "  - Completed: $COMPLETED_TASKS"
    echo "  - Failed: $FAILED_TASKS"
else
    echo "No tasks.json found. Task management not initialized."
fi
echo ""

echo "--- Recent Activity (Last 5 Files Modified) ---"
ls -lt --time-style=long-iso ./data/ | head -n 6 | tail -n 5
echo ""

echo "--- System Health ---"
echo "Disk Usage:"
df -h . | tail -n 1 | awk '{print "  - Available: " $4 ", Capacity: " $5}'
echo "Uptime: $(uptime -p)"
echo ""
echo "=============================================="
