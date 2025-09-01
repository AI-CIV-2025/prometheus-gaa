#!/bin/bash

# Generic error logging script.
# Usage: ./data/scripts/log_error.sh "Error message description" "Contextual information"

ERROR_MSG="$1"
CONTEXT="$2"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="./data/logs/system_errors.log"

echo "[$TIMESTAMP] ERROR: $ERROR_MSG" >> "$LOG_FILE"
if [ -n "$CONTEXT" ]; then
    echo "[$TIMESTAMP] CONTEXT: $CONTEXT" >> "$LOG_FILE"
fi

echo "Error logged to $LOG_FILE"
