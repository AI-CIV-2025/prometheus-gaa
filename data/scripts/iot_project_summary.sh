#!/bin/bash
# iot_project_summary.sh - Summarizes artifacts related to the IoT Dashboard project

echo "=== Real-time IoT Analytics Dashboard Project Artifacts Summary ==="
echo "Generated On: $(date)"
echo "Execution Path: ${EXECUTION_PATH:-./data}"
echo ""

echo "## 1. Project Files Overview"
echo "---------------------------------"
if [ -d "./data" ]; then
    find "./data" -maxdepth 1 -type f -name "*iot*" -o -name "*claudeC*" -o -name "*analysis*" | sort | while read -r file; do
        filename=$(basename "$file")
        filesize=$(du -h "$file" | awk '{print $1}')
        filetype=$(file -b --mime-type "$file")
        echo "- $filename ($filesize, $filetype)"
    done
else
    echo "No ./data directory found."
fi
echo ""

echo "## 2. File Type Breakdown (IoT Related)"
echo "-------------------------------------"
TOTAL_FILES=$(find "./data" -maxdepth 1 -type f -name "*iot*" -o -name "*claudeC*" -o -name "*analysis*" | wc -l)
CODE_FILES=$(find "./data" -maxdepth 1 -type f -name "*iot*.py" -o -name "*iot*.js" -o -name "*iot*.sh" -o -name "*claudeC*.py" -o -name "*claudeC*.js" -o -name "*claudeC*.sh" | wc -l)
DOC_FILES=$(find "./data" -maxdepth 1 -type f -name "*iot*.md" -o -name "*claudeC*.md" -o -name "*analysis*.md" | wc -l)
CONFIG_FILES=$(find "./data" -maxdepth 1 -type f -name "*iot*.json" -o -name "*iot*.yaml" -o -name "*claudeC*.json" -o -name "*claudeC*.yaml" | wc -l)
OTHER_FILES=$((TOTAL_FILES - CODE_FILES - DOC_FILES - CONFIG_FILES))

echo "Total IoT-related files: $TOTAL_FILES"
echo "  - Code/Script files: $CODE_FILES"
echo "  - Documentation files: $DOC_FILES"
echo "  - Configuration files: $CONFIG_FILES"
echo "  - Other files: $OTHER_FILES"
echo ""

echo "## 3. Recent Activity (Last 5 IoT-related files modified)"
echo "---------------------------------------------------"
ls -lt ./data/*iot* ./data/*claudeC* ./data/*analysis* 2>/dev/null | head -n 5 || echo "No recent IoT-related files found."
echo ""

echo "## 4. Key Artifacts Status"
echo "---------------------------"
[ -f "./data/claudeC_iot_dashboard_req" ] && echo "✔️ ClaudeC IoT Dashboard Request: Present" || echo "❌ ClaudeC IoT Dashboard Request: Not Found"
[ -f "./data/iot_dashboard_analysis_plan.md" ] && echo "✔️ IoT Dashboard Analysis Plan: Present" || echo "❌ IoT Dashboard Analysis Plan: Not Found"
[ -f "./data/ai_ai_iot_collaboration_report_template.md" ] && echo "✔️ AI-AI Collaboration Report Template: Present" || echo "❌ AI-AI Collaboration Report Template: Not Found"
[ -f "./data/iot_project_summary.sh" ] && echo "✔️ IoT Project Summary Script: Present" || echo "❌ IoT Project Summary Summary Script: Not Found"

