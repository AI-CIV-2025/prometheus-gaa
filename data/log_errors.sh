#!/bin/bash
# Log errors and warnings to system.log

log_message() {
  echo "$(date) - $1" >> ./data/system.log
}

# Example usage:
# log_message "Warning: Something went wrong."
# log_message "Error: Critical failure occurred."
