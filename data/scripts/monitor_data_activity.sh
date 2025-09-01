#!/bin/bash

# Data Activity Monitoring Script
# This script provides an overview of file activity and statistics within the ./data directory.
# It is designed to help track the system's output and resource usage.

echo "=== Data Activity Monitor - $(date) ==="
echo ""

echo "## 1. Current Directory: $(pwd)"
echo "   Monitoring Path: ${EXECUTION_PATH:-./data}"
echo ""

echo "## 2. Disk Usage Summary"
df -h . | head -n 1
df -h . | tail -n 1
echo ""

echo "## 3. Directory Size"
du -sh ${EXECUTION_PATH:-./data}
echo ""

echo "## 4. File Type Statistics"
echo "   - Total files: $(ls -1 ${EXECUTION_PATH:-./data}/ 2>/dev/null | wc -l)"
echo "   - Markdown reports/docs: $(ls -1 ${EXECUTION_PATH:-./data}/*.md 2>/dev/null | wc -l)"
echo "   - Shell scripts: $(ls -1 ${EXECUTION_PATH:-./data}/*.sh 2>/dev/null | wc -l)"
echo "   - JSON configurations: $(ls -1 ${EXECUTION_PATH:-./data}/*.json 2>/dev/null | wc -l)"
echo "   - Text files: $(ls -1 ${EXECUTION_PATH:-./data}/*.txt 2>/dev/null | wc -l)"
echo "   - Log files: $(ls -1 ${EXECUTION_PATH:-./data}/*.log 2>/dev/null | wc -l)"
echo ""

echo "## 5. Most Recently Modified Files (Top 10)"
echo "   (Path: ${EXECUTION_PATH:-./data})"
ls -lt ${EXECUTION_PATH:-./data}/ 2>/dev/null | head -n 10
echo ""

echo "## 6. Recent Report Generation"
echo "   (Path: ${EXECUTION_PATH:-./data}/reports)"
ls -lt ${EXECUTION_PATH:-./data}/reports/ 2>/dev/null | head -n 5
echo ""

echo "## 7. Tool Library Status"
echo "   (Path: ${EXECUTION_PATH:-./data}/tools)"
ls -lt ${EXECUTION_PATH:-./data}/tools/ 2>/dev/null | head -n 5
echo ""

echo "## 8. Knowledge Base Status"
echo "   (Path: ${EXECUTION_PATH:-./data}/knowledge)"
ls -lt ${EXECUTION_PATH:-./data}/knowledge/ 2>/dev/null | head -n 5
echo ""

echo "=== Monitoring Complete ==="
