#!/bin/bash

# Example of improved error handling
if [ ! -f ./data/nonexistent_file.txt ]; then
  echo "Error: ./data/nonexistent_file.txt not found." >&2 # Redirect to stderr
  exit 1
else
  cat ./data/nonexistent_file.txt
fi
