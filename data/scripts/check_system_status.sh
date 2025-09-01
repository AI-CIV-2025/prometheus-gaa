#!/bin/bash

# Script to check the overall status of the GAA system components.
# It verifies the presence and basic health of key directories and files.

echo "--- GAA System Status Check ---"
echo "Timestamp: $(date)"
echo ""

STATUS="OK"

# Check core directories
CORE_DIRS=("scripts" "configs" "docs" "logs" "tests" "src")
for dir in "${CORE_DIRS[@]}"; do
    if [ -d "./data/$dir" ]; then
        echo "[OK] Directory ./data/$dir exists."
    else
        echo "[FAIL] Directory ./data/$dir is missing."
        STATUS="WARNING"
    fi
done

# Check for essential files
ESSENTIAL_FILES=("./README.md" "./data/scripts/validate_yaml.sh" "./data/scripts/log_error.sh")
for file in "${ESSENTIAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "[OK] File $file exists."
    else
        echo "[FAIL] File $file is missing."
        STATUS="WARNING"
    fi
done

# Check log file existence and size (basic check)
LOG_FILE="./data/logs/system_errors.log"
if [ -f "$LOG_FILE" ]; then
    echo "[OK] Log file $LOG_FILE exists."
    if [ $(stat -c%s "$LOG_FILE") -gt 0 ]; then
        echo "  - Log file contains entries."
    else
        echo "  - Log file is empty."
    fi
else
    echo "[INFO] Log file $LOG_FILE does not exist yet (no errors logged)."
fi

echo ""
echo "Overall System Status: $STATUS"
echo "-----------------------------"

exit 0
