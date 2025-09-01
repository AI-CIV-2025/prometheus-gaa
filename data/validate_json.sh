#!/bin/bash
# validate_json.sh
# Purpose: Validate all .json files in the ./data directory using jq.
# Usage: ./data/validate_json.sh

JSON_FILES=$(find ./data -maxdepth 1 -name "*.json" 2>/dev/null)

if [ -z "$JSON_FILES" ]; then
  echo "No JSON files found in ./data/ to validate."
  exit 0
fi

echo "--- Validating JSON files in ./data/ ---"
VALID_COUNT=0
INVALID_COUNT=0

for FILE in $JSON_FILES; do
  if jq '.' "$FILE" > /dev/null 2>&1; then
    echo "✅ $FILE is valid JSON."
    ((VALID_COUNT++))
  else
    echo "❌ $FILE is invalid JSON."
    # Use the error logging script for invalid JSON
    ./data/log_error.sh "Invalid JSON detected: $FILE"
    ((INVALID_COUNT++))
  fi
done

echo ""
echo "--- Validation Summary ---"
echo "Total JSON files found: $((VALID_COUNT + INVALID_COUNT))"
echo "Valid JSON files: $VALID_COUNT"
echo "Invalid JSON files: $INVALID_COUNT"

if [ $INVALID_COUNT -gt 0 ]; then
  exit 1
fi
exit 0
