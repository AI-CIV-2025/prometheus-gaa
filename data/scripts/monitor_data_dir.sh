#!/bin/bash

echo "--- Data Directory Monitoring Report ---"
echo "Generated: $(date)"
echo "Execution Path: ${EXECUTION_PATH:-./data}"
echo ""

echo "## 1. Disk Usage of ./data"
du -sh ./data 2>/dev/null || echo "Error: Could not determine disk usage."
echo ""

echo "## 2. File Count by Type in ./data"
echo "- Total files: $(find ./data -type f 2>/dev/null | wc -l)"
echo "- Markdown files (.md): $(find ./data -name "*.md" 2>/dev/null | wc -l)"
echo "- Shell scripts (.sh): $(find ./data -name "*.sh" 2>/dev/null | wc -l)"
echo "- Log files (.log): $(find ./data -name "*.log" 2>/dev/null | wc -l)"
echo "- JSON files (.json): $(find ./data -name "*.json" 2>/dev/null | wc -l)"
echo "- Text files (.txt): $(find ./data -name "*.txt" 2>/dev/null | wc -l)"
echo ""

echo "## 3. Recently Modified Files (Top 5)"
ls -lt ./data 2>/dev/null | head -n 6 || echo "No files found or recent modifications."
echo ""

echo "## 4. Status of exec_policy.json"
if [ -f ./exec_policy.json ]; then
    echo "exec_policy.json: Present"
    echo "File size: $(du -h ./exec_policy.json | awk '{print $1}')"
else
    echo "exec_policy.json: Not Found"
fi
echo ""
echo "--- End of Report ---"
