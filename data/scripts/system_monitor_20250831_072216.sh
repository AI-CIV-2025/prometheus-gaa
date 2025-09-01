#!/bin/bash

# System Monitoring Script for GAA-4.0
# Generated: $(date)

# Log file will be created in the data directory
LOG_FILE="${EXECUTION_PATH}/system_monitor_log_$(date +%Y%m%d).log"

# Function to log a message
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check disk usage
check_disk_usage() {
    log_message "--- Disk Usage ---"
    df -h . | tee -a "$LOG_FILE"
}

# Function to check memory usage
check_memory_usage() {
    log_message "--- Memory Usage ---"
    free -h | tee -a "$LOG_FILE"
}

# Function to list top processes by CPU
check_top_processes() {
    log_message "--- Top 5 Processes by CPU ---"
    ps aux --sort=-%cpu | head -n 6 | tee -a "$LOG_FILE"
}

# Function to count files in the execution path
count_data_files() {
    log_message "--- Data Directory File Count ---"
    echo "Total files in ${EXECUTION_PATH}: $(find "${EXECUTION_PATH}" -type f | wc -l)" | tee -a "$LOG_FILE"
    echo "Markdown files: $(find "${EXECUTION_PATH}" -name "*.md" | wc -l)" | tee -a "$LOG_FILE"
    echo "Shell scripts: $(find "${EXECUTION_PATH}" -name "*.sh" | wc -l)" | tee -a "$LOG_FILE"
    echo "JSON files: $(find "${EXECUTION_PATH}" -name "*.json" | wc -l)" | tee -a "$LOG_FILE"
    echo "Log files: $(find "${EXECUTION_PATH}" -name "*.log" | wc -l)" | tee -a "$LOG_FILE"
}

# Main monitoring execution
log_message "Starting System Monitoring Report"
check_disk_usage
check_memory_usage
check_top_processes
count_data_files
log_message "System Monitoring Report Finished"

echo "Monitoring log saved to $LOG_FILE"
