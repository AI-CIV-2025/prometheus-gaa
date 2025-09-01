#!/bin/bash

# Function to log messages
log() {
  echo "Sun Aug 31 11:52:46 EDT 2025 - " >> ./data/system.log
}

# Attempt to create a directory
mkdir ./data/new_directory 2>> ./data/error.log
if [ 0 -eq 0 ]; then
  log "Successfully created directory ./data/new_directory"
else
  log "Failed to create directory ./data/new_directory. Error: "
fi

# Attempt to read a non-existent file
cat ./data/non_existent_file 2>> ./data/error.log
if [ 1 -eq 0 ]; then
  log "Successfully read file ./data/non_existent_file"
else
  log "Failed to read file ./data/non_existent_file. Error: "
fi
