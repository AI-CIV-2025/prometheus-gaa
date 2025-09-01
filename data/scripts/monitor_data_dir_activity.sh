#!/bin/bash
# Data Directory Activity Monitor Script
# This script provides an overview of the contents and recent activity within the ./data directory.

echo "=== Data Directory Activity Report ==="
echo "Generated: $(date)"
echo "Monitoring Path: ${EXECUTION_PATH:-./data}"
echo ""

echo "--- Directory Structure ---"
ls -F ./data/ | grep '/' | sed 's/.$//' | awk '{print "- " $1 " (directory)"}' || echo "No subdirectories found."
echo ""

echo "--- File Type Summary (in ./data/ and subdirectories) ---"
echo "- Total files: $(find ./data -type f 2>/dev/null | wc -l)"
echo "- Markdown files (*.md): $(find ./data -name "*.md" 2>/dev/null | wc -l)"
echo "- Shell scripts (*.sh): $(find ./data -name "*.sh" 2>/dev/null | wc -l)"
echo "- JSON files (*.json): $(find ./data -name "*.json" 2>/dev/null | wc -l)"
echo "- Log files (*.log): $(find ./data -name "*.log" 2>/dev/null | wc -l)"
echo "- Other files: $(find ./data -type f ! -name "*.md" ! -name "*.sh" ! -name "*.json" ! -name "*.log" 2>/dev/null | wc -l)"
echo ""

echo "--- Top 10 Recently Modified Files ---"
ls -lt ./data/ 2>/dev/null | head -n 11 | tail -n 10 || echo "No files found or error listing."
echo ""

echo "--- Disk Usage of ./data/ ---"
du -sh ./data/ 2>/dev/null || echo "Could not determine disk usage."
echo ""

echo "--- End of Report ---"
