#!/bin/bash
echo "=== AI-AI Collaboration Artifact Analysis ==="
echo "Analysis Date: $(date)"
echo ""

echo "## Collaboration Log (ai_ai_collaboration_log.md)"
if [ -f "./data/ai_ai_collaboration_log.md" ]; then
    echo "  - Exists: Yes"
    echo "  - Size: $(du -h ./data/ai_ai_collaboration_log.md | awk '{print $1}')"
    echo "  - Last 5 entries:"
    tail -n 15 ./data/ai_ai_collaboration_log.md | grep -E "^# AI-AI Collaboration Log Entry:" || echo "    (Less than 5 entries or no matching lines)"
else
    echo "  - Exists: No"
fi
echo ""

echo "## Claude Code Request (claudeC_request.md)"
if [ -f "./data/claudeC_request.md" ]; then
    echo "  - Exists: Yes"
    echo "  - Size: $(du -h ./data/claudeC_request.md | awk '{print $1}')"
    echo "  - First 5 lines:"
    head -n 5 ./data/claudeC_request.md
else
    echo "  - Exists: No"
fi
echo ""

echo "## Claude Code Response Staging Area (claudeC_response_staging/)"
if [ -d "./data/claudeC_response_staging" ]; then
    echo "  - Exists: Yes"
    echo "  - Contents:"
    ls -la ./data/claudeC_response_staging/
else
    echo "  - Exists: No"
fi
echo ""

echo "## Collaboration Status Reports"
if ls ./data/ai_ai_collaboration_status_report_*.md 1> /dev/null 2>&1; then
    echo "  - Count: $(ls ./data/ai_ai_collaboration_status_report_*.md | wc -l)"
    echo "  - Most Recent:"
    ls -t ./data/ai_ai_collaboration_status_report_*.md | head -n 1
else
    echo "  - No status reports found."
fi
echo ""

echo "## Overall Data Directory Summary:"
ls -lh ./data/
