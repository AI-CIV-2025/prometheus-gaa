#!/bin/bash
LOG_DIR="./data/logs"
ERROR_LOG="${LOG_DIR}/error.log"
INFO_LOG="${LOG_DIR}/info.log"

# Ensure log directory exists
mkdir -p "${LOG_DIR}"

log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - INFO - $1" >> "${INFO_LOG}"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR - $1" >> "${ERROR_LOG}"
}

# Example usage:
# log_info "System startup complete."
# log_error "Failed to process file: non_existent_file.txt"

echo "Enhanced logging script created at ./data/scripts/stability/enhanced_logging.sh"
echo "Log files will be generated in ./data/logs/"
