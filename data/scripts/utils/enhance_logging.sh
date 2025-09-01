#!/bin/bash

LOG_DIR="./data/logs"
mkdir -p "$LOG_DIR"

# Function to log messages with timestamp and severity
log_message() {
    local severity="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$severity] $message" >> "$LOG_DIR/system.log"
}

# Function to log errors
log_error() {
    local message="$1"
    log_message "ERROR" "$message"
}

# Function to log informational messages
log_info() {
    local message="$1"
    log_message "INFO" "$message"
}

# Example usage:
# log_info "System started successfully."
# log_error "Failed to process data."

echo "Logging functions defined. Log file: $LOG_DIR/system.log"
