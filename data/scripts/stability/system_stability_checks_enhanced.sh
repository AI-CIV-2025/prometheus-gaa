#!/bin/bash

LOG_DIR="./data/logs/system"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Ensure log directory exists
mkdir -p "$LOG_DIR"

log_message() {
  local message="$1"
  echo "[$TIMESTAMP] $message" | tee -a "$LOG_DIR/stability_check.log"
}

log_message "--- GAA System Stability Check ---"

log_message "Checking for common issues..."

# Check for orphaned processes (basic check, might need refinement)
ORPHAN_COUNT=$(ps -ef --no-headers | awk '$3 == 1 {print $2}' | wc -l)
log_message "Orphaned processes count: $ORPHAN_COUNT"

# Check disk space usage
log_message "Disk usage for current directory:"
df -h . | tail -1 | tee -a "$LOG_DIR/stability_check.log"

# Check for recent error logs (assuming logs are in ./data/logs/)
if [ -d "./data/logs" ]; then
  log_message "Recent errors in logs:"
  # Look for lines containing "error", "fail", "critical" in the last 24 hours
  ERROR_REPORTS=$(find ./data/logs -name "*.log" -type f -mtime -1 -exec grep -Ei "error|fail|critical" {} \; 2>/dev/null || echo "No recent critical errors found.")
  echo "$ERROR_REPORTS" | tee -a "$LOG_DIR/stability_check.log"
else
  log_message "Log directory ./data/logs not found."
fi

# Check for any files with unusual permissions (e.g., world-writable)
log_message "Files with unusual permissions (world-writable):"
UNUSUAL_PERMISSIONS=$(find . -type f -perm -o+w -print 2>/dev/null || echo "No world-writable files found.")
echo "$UNUSUAL_PERMISSIONS" | tee -a "$LOG_DIR/stability_check.log"

log_message "--- Stability Check Complete ---"
