#!/bin/bash
# monitor_system_health.sh
# A script to monitor basic system health and resource utilization.

# --- Configuration ---
LOG_DIR="./data/logs"
REPORTS_DIR="./data/reports"
HEALTH_CHECK_FILE="./data/health_check.log"
MAX_LOG_FILES=10
MAX_REPORT_FILES=5

# --- Ensure directories exist ---
mkdir -p "$LOG_DIR"
mkdir -p "$REPORTS_DIR"

# --- Timestamp ---
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
DATE_TAG=$(date +"%Y%m%d_%H%M%S")

# --- Function to log messages ---
log_message() {
    local message="$1"
    echo "$TIMESTAMP - $message" >> "$HEALTH_CHECK_FILE"
    echo "$TIMESTAMP - $message" # Also output to stdout
}

# --- Perform Health Checks ---
log_message "Starting system health check..."

# Disk Usage Check
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 85 ]; then
    log_message "WARNING: Disk usage is high: ${DISK_USAGE}%"
else
    log_message "INFO: Disk usage is nominal: ${DISK_USAGE}%"
fi

# Number of Log Files Check
NUM_LOG_FILES=$(ls -1 "$LOG_DIR"/*.log 2>/dev/null | wc -l)
if [ "$NUM_LOG_FILES" -gt "$MAX_LOG_FILES" ]; then
    log_message "WARNING: Exceeding maximum log file count. Current: $NUM_LOG_FILES (Max: $MAX_LOG_FILES)"
else
    log_message "INFO: Log file count is nominal: $NUM_LOG_FILES"
fi

# Number of Report Files Check
NUM_REPORT_FILES=$(ls -1 "$REPORTS_DIR"/*.md 2>/dev/null | wc -l)
if [ "$NUM_REPORT_FILES" -gt "$MAX_REPORT_FILES" ]; then
    log_message "WARNING: Exceeding maximum report file count. Current: $NUM_REPORT_FILES (Max: $MAX_REPORT_FILES)"
else
    log_message "INFO: Report file count is nominal: $NUM_REPORT_FILES"
fi

# Basic System Uptime Check
UPTIME_SECONDS=$(awk '{print int($1)}' /proc/uptime)
if [ "$UPTIME_SECONDS" -lt 600 ]; then # Less than 10 minutes
    log_message "INFO: System recently started."
fi

# Check for critical errors in recent logs (example: looking for "ERROR" or "CRITICAL")
RECENT_LOG_ERRORS=$(grep -i -E "ERROR|CRITICAL" "$LOG_DIR"/*.log 2>/dev/null | tail -n 5)
if [ -n "$RECENT_LOG_ERRORS" ]; then
    log_message "CRITICAL: Found recent errors in logs:"
    echo "$RECENT_LOG_ERRORS" >> "$HEALTH_CHECK_FILE"
    echo "$RECENT_LOG_ERRORS"
else
    log_message "INFO: No critical errors found in recent logs."
fi

log_message "System health check completed."

# --- Cleanup Old Files (Optional - implement with caution) ---
# Example: Remove logs older than 7 days
# find "$LOG_DIR" -name "*.log" -type f -mtime +7 -delete
# Example: Remove reports older than 30 days
# find "$REPORTS_DIR" -name "*.md" -type f -mtime +30 -delete

exit 0
