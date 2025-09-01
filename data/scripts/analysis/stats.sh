#!/bin/bash
echo "=== GAA-4.0 Execution Statistics ==="
echo "Generated: $(date)"
echo ""
echo "File Statistics:"
echo "- Total files in data/: $(ls -1 ./data/ 2>/dev/null | wc -l)"
echo "- Log files: $(ls -1 ./data/*.log 2>/dev/null | wc -l)"
echo "- JSON files: $(ls -1 ./data/*.json 2>/dev/null | wc -l)"
echo "- Text files: $(ls -1 ./data/*.txt 2>/dev/null | wc -l)"
echo "- Markdown files: $(ls -1 ./data/*.md 2>/dev/null | wc -l)"
echo ""
echo "Disk Usage:"
df -h . | tail -1
echo ""
echo "Recent Activity (Last 10 Modified Files):"
ls -lt ./data/ 2>/dev/null | head -10
echo ""
echo "Top 5 Largest Files:"
ls -lS ./data/ 2>/dev/null | head -6 | tail -5
