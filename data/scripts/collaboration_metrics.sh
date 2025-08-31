#!/bin/bash
# This script tracks key metrics for AI-AI collaboration.

METRICS_LOG="./data/logs/collaboration_metrics.log"
EXECUTION_SUMMARY="./data/execution_summary_$(date +%Y%m%d_%H%M%S).log"
REPORT_DIR="./data/reports"
SCRIPT_DIR="./data/scripts"
DOC_DIR="./data/documentation"

echo "--- Collaboration Metrics Log ---" > "\$METRICS_LOG"
echo "Timestamp: $(date)" >> "\$METRICS_LOG"
echo "" >> "\$METRICS_LOG"

echo "--- Execution Summary Log ---" > "\$EXECUTION_SUMMARY"
echo "Execution Timestamp: $(date)" >> "\$EXECUTION_SUMMARY"
echo "" >> "\$EXECUTION_SUMMARY"

# Metric 1: Number of scripts in the scripts directory
NUM_SCRIPTS=$(ls -1 "\$SCRIPT_DIR" 2>/dev/null | wc -l)
echo "Number of scripts available: \$NUM_SCRIPTS" >> "\$METRICS_LOG"
echo "✅ SUCCESS: Found \$NUM_SCRIPTS scripts in \$SCRIPT_DIR" >> "\$EXECUTION_SUMMARY"

# Metric 2: Number of documentation files
NUM_DOCS=$(ls -1 "\$DOC_DIR" 2>/dev/null | wc -l)
echo "Number of documentation files: \$NUM_DOCS" >> "\$METRICS_LOG"
echo "✅ SUCCESS: Found \$NUM_DOCS documentation files in \$DOC_DIR" >> "\$EXECUTION_SUMMARY"

# Metric 3: Number of reports generated
NUM_REPORTS=$(ls -1 "\$REPORT_DIR" 2>/dev/null | wc -l)
echo "Number of reports generated: \$NUM_REPORTS" >> "\$METRICS_LOG"
echo "✅ SUCCESS: Found \$NUM_REPORTS reports in \$REPORT_DIR" >> "\$EXECUTION_SUMMARY"

# Metric 4: Last modified file in the data directory (excluding logs and temp files)
LAST_MODIFIED=$(find ./data -type f ! -name "*.log" ! -name "*.tmp" -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2- || echo "N/A")
echo "Most recently modified artifact (excluding logs): \$LAST_MODIFIED" >> "\$METRICS_LOG"
echo "✅ SUCCESS: Identified last modified artifact: \$LAST_MODIFIED" >> "\$EXECUTION_SUMMARY"

echo "" >> "\$METRICS_LOG"
echo "Metrics collection complete." >> "\$METRICS_LOG"

echo "Execution summary complete." >> "\$EXECUTION_SUMMARY"

# Make the script executable
chmod +x "\$METRICS_LOG"
chmod +x "\$EXECUTION_SUMMARY"

# Execute the metrics script to generate the log file
./data/scripts/collaboration_metrics.sh
