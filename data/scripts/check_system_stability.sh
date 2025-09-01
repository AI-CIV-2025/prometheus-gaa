#!/bin/bash

LOG_DIR="${EXECUTION_PATH}"
MAX_LOG_SIZE_MB=50 # Maximum allowed size for a single log file in MB
TOTAL_LOG_SIZE_LIMIT_GB=1 # Total limit for all log files in GB
LOG_RETENTION_DAYS=7 # Number of days to keep log files

echo "=== GAA System Stability & Logging Check ==="
echo "Timestamp: $(date)"
echo "Execution Path: ${EXECUTION_PATH}"
echo ""

# Check for core system files existence
echo "--- Core File Check ---"
FILES_TO_CHECK=("README.md" "exec_policy.json" "system_config.yaml" "validate_yaml.py" "check_api_efficiency.py")
for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "${LOG_DIR}/${file}" ]; then
        echo "[OK] ${file} exists."
    else
        echo "[WARN] ${file} is MISSING."
    fi
done
echo ""

# Check log file sizes and count
echo "--- Log File Analysis ---"

# Find all files in the log directory that look like logs (e.g., .log extension)
# Adjust find command if your log naming convention is different
LOG_FILES=$(find "${LOG_DIR}" -maxdepth 1 -name "*.log" -o -name "*.err" -o -name "*.out" 2>/dev/null)

if [ -z "$LOG_FILES" ]; then
    echo "No log files found in ${LOG_DIR}."
else
    FILE_COUNT=$(echo "$LOG_FILES" | wc -l)
    echo "Found ${FILE_COUNT} log file(s)."
    
    TOTAL_SIZE_BYTES=0
    OVER_SIZE_LIMIT=0
    
    echo "$LOG_FILES" | while IFS= read -r log_file; do
        if [ -f "$log_file" ]; then
            FILE_SIZE_BYTES=$(stat -c%s "$log_file")
            FILE_SIZE_MB=$(echo "$FILE_SIZE_BYTES / 1024 / 1024" | bc)
            TOTAL_SIZE_BYTES=$((TOTAL_SIZE_BYTES + FILE_SIZE_BYTES))
            
            echo -n "  - ${log_file##*/}: ${FILE_SIZE_MB} MB"
            
            if [ "$FILE_SIZE_MB" -gt "$MAX_LOG_SIZE_MB" ]; then
                echo " [WARN: Exceeds ${MAX_LOG_SIZE_MB} MB limit]"
                OVER_SIZE_LIMIT=$((OVER_SIZE_LIMIT + 1))
            else
                echo ""
            fi
        fi
    done
    
    TOTAL_SIZE_GB=$(echo "$TOTAL_SIZE_BYTES / 1024 / 1024 / 1024" | bc)
    echo ""
    echo "Total log size: ${TOTAL_SIZE_GB} GB"
    
    if [ $(echo "$TOTAL_SIZE_GB > $TOTAL_LOG_SIZE_LIMIT_GB" | bc) -eq 1 ]; then
        echo "[WARN: Total log size exceeds ${TOTAL_LOG_SIZE_LIMIT_GB} GB limit]"
    else
        echo "[OK] Total log size is within limits."
    fi
    
    if [ "$OVER_SIZE_LIMIT" -gt 0 ]; then
        echo "[WARN] ${OVER_SIZE_LIMIT} log file(s) exceed individual size limits."
    else
        echo "[OK] All individual log files are within size limits."
    fi
fi
echo ""

# Check for recent log activity (last modified files)
echo "--- Recent Log Activity ---"
if [ -n "$LOG_FILES" ]; then
    ls -lt --time-style=long-iso "${LOG_DIR}" | grep -E '(\.log|\.err|\.out)$' | head -5 || echo "No recent log files found."
else
    echo "No log files to check for recent activity."
fi
echo ""

# Check for specific error patterns in logs (example: 'ERROR', 'Exception')
# This requires logs to be present. Add more patterns as needed.
echo "--- Error Pattern Check in Logs ---"
ERROR_PATTERNS=("ERROR" "Exception" "Traceback")
found_errors=0
if [ -n "$LOG_FILES" ]; then
    for pattern in "${ERROR_PATTERNS[@]}"; do
        # Use grep -i for case-insensitive search
        matches=$(grep -i "$pattern" $LOG_FILES 2>/dev/null | wc -l)
        if [ "$matches" -gt 0 ]; then
            echo "[WARN] Found ${matches} occurrences of '${pattern}' in log files."
            found_errors=1
        fi
    done
    if [ "$found_errors" -eq 0 ]; then
        echo "No specific error patterns found in log files."
    fi
else
    echo "No log files to check for error patterns."
fi
echo ""

# Basic disk space check
echo "--- Disk Space Check ---"
df -h "${LOG_DIR}" | tail -n 1
echo ""

# Check if required Python dependencies are potentially available (basic check)
# This is a very rough check; proper dependency management is external.
echo "--- Python Environment Check (Basic) ---"
echo "Checking for 'PyYAML' availability (used by validate_yaml.py):"
if python3 -c "import yaml" &> /dev/null; then
    echo "[OK] PyYAML seems to be installed."
else
    echo "[WARN] PyYAML might not be installed. Ensure it's available for validate_yaml.py."
fi

echo "Checking for 'time', 'sys', 'os' availability (standard Python modules):"
if python3 -c "import time, sys, os" &> /dev/null; then
    echo "[OK] Standard Python modules (time, sys, os) are available."
else
    echo "[FAIL] Standard Python modules are not available. Python environment is broken."
fi
echo ""

echo "=== Stability & Logging Check Complete ==="
