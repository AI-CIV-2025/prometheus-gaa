#!/bin/bash

echo "=== System Health and Activity Monitor ==="
echo "Report Generated: $(date)"
echo "Execution Path: ${EXECUTION_PATH:-./data}"
echo ""

echo "--- Disk Usage ---"
df -h . | tail -n 1
echo ""

echo "--- File Statistics in ${EXECUTION_PATH} ---"
echo "- Total files: $(ls -1 "${EXECUTION_PATH}" 2>/dev/null | wc -l)"
echo "- Reports (.md): $(find "${EXECUTION_PATH}/reports" -name "*.md" 2>/dev/null | wc -l)"
echo "- Tools (.sh): $(find "${EXECUTION_PATH}/tools" -name "*.sh" 2>/dev/null | wc -l)"
echo "- Knowledge Base (.md): $(find "${EXECUTION_PATH}/knowledge" -name "*.md" 2>/dev/null | wc -l)"
echo "- Log files (.log): $(find "${EXECUTION_PATH}" -name "*.log" 2>/dev/null | wc -l)"
echo "- JSON files (.json): $(find "${EXECUTION_PATH}" -name "*.json" 2>/dev/null | wc -l)"
echo ""

echo "--- Recent Activity (Last 5 modified files in ${EXECUTION_PATH}) ---"
ls -lt "${EXECUTION_PATH}" 2>/dev/null | head -n 6
echo ""

echo "--- Policy File Status ---"
if [ -f "./exec_policy.json" ]; then
    echo "exec_policy.json found. Size: $(du -h ./exec_policy.json | awk '{print $1}')"
else
    echo "exec_policy.json NOT found."
fi
echo ""
echo "Monitoring complete."
