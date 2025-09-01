#!/bin/bash
# Display the contents of system.log

if [ ! -f "./data/system.log" ]; then
  echo "Error: system.log file not found."
  exit 1
fi

echo "=== System Logs ==="
cat ./data/system.log
