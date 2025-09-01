#!/bin/bash

LOG_DIR="./data/logs"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Log function
log_message() {
    local level="$1"
    local message="$2"
    echo "[$TIMESTAMP] [$level] $message" >> "$LOG_DIR/system.log"
}

# Example usage:
# log_message "INFO" "System startup initiated."
# log_message "WARN" "Potential issue detected: High CPU usage."
# log_message "ERROR" "Failed to connect to database."

echo "Enhanced logger script created in ./data/enhanced_logger.sh"
