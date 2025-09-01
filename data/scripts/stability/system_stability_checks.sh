#!/bin/bash
# Script to perform basic system stability checks

echo "--- System Stability Checks ---"
echo "Timestamp: $(date)"
echo "Execution Path: ${EXECUTION_PATH}"
echo ""

echo "Checking file system integrity..."
# Check if essential directories exist
if [ ! -d "${EXECUTION_PATH}" ]; then
  echo "ERROR: Execution path '${EXECUTION_PATH}' does not exist."
  exit 1
fi
if [ ! -d "${EXECUTION_PATH}/scripts/stability" ]; then
  echo "WARNING: Stability scripts directory '${EXECUTION_PATH}/scripts/stability' is missing. Attempting to create..."
  mkdir -p "${EXECUTION_PATH}/scripts/stability" || { echo "ERROR: Failed to create directory."; exit 1; }
fi
 if [ ! -d "${EXECUTION_PATH}/scripts/monitoring" ]; then
  echo "WARNING: Monitoring scripts directory '${EXECUTION_PATH}/scripts/monitoring' is missing. Attempting to create..."
  mkdir -p "${EXECUTION_PATH}/scripts/monitoring" || { echo "ERROR: Failed to create directory."; exit 1; }
fi
echo "File system check completed."
echo ""

echo "Checking available disk space..."
df -h "${EXECUTION_PATH}" | tail -1 | awk '{print "  Available space in " $6 ": " $4}'
echo ""

echo "Checking log file existence (basic check)..."
# Example: Check for any .log files in the execution path
log_files=$(find "${EXECUTION_PATH}" -name "*.log" 2>/dev/null | wc -l)
echo "  Found ${log_files} log file(s) in ${EXECUTION_PATH}."
echo ""

echo "System stability checks finished."
exit 0
