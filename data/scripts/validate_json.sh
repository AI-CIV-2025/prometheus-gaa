#!/bin/bash
# Validates a JSON file using jq

JSON_FILE="$1"

if [ -z "$JSON_FILE" ]; then
  echo "Usage: validate_json.sh <path_to_json_file>"
  exit 1
fi

if [ ! -f "$JSON_FILE" ]; then
  echo "Error: File '$JSON_FILE' not found."
  exit 1
fi

if command -v jq &> /dev/null; then
  if jq -e . "$JSON_FILE" > /dev/null 2>&1; then
    echo "'$JSON_FILE' is valid JSON."
    exit 0
  else
    echo "Error: '$JSON_FILE' is not valid JSON."
    exit 1
  fi
else
  echo "Error: jq is not installed. Please install jq to validate JSON files."
  exit 1
fi
