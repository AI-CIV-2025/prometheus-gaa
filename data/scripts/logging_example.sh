#!/bin/bash
# Log message to file
log_message() {
  echo "$(date) - $1" >> ./data/logs/system.log
}

# Example usage
log_message "System started"
# Your commands here
log_message "System completed"
