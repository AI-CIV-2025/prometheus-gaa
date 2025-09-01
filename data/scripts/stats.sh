#!/bin/bash
# Redirect output to a log file
exec &> ./data/stats.log

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
echo "Recent Activity:"
ls -lt ./data/ 2>/dev/null | head -10
echo ""
echo "=== End of Statistics ==="
