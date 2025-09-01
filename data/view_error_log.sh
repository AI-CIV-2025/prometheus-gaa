#!/bin/bash
if [ -f ./data/error_log.txt ]; then
  echo "=== Error Log ==="
  cat ./data/error_log.txt
else
  echo "Error log file ./data/error_log.txt not found."
fi
