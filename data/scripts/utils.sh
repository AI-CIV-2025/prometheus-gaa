#!/bin/bash
# Utility functions for the GAA system

log_message() {
  local level="$1"
  local message="$2"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "[$timestamp] [$level] $message" >> ./data/system.log
}

# Example of a function that might be used
process_data() {
  local input_file="$1"
  local output_file="$2"
  log_message "INFO" "Processing data from $input_file to $output_file"
  cat "$input_file" | sed 's/old/new/g' > "$output_file"
  if [ \$? -eq 0 ]; then
    log_message "INFO" "Successfully processed $input_file"
  else
    log_message "ERROR" "Failed to process $input_file"
  fi
}
