#!/bin/bash
# Validate YAML file
if ! command -v yq >/dev/null 2>&1; then
  echo "Error: yq is not installed. Please install it."
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: ./validate_yaml.sh <yaml_file>"
  exit 1
fi

yaml_file="$1"

if [ ! -f "$yaml_file" ]; then
  echo "Error: File '$yaml_file' not found."
  echo "Error: File '$yaml_file' not found." >> ./data/validation_log.txt
  exit 1
fi

echo "Validating YAML file '$yaml_file'..."
echo "Validating YAML file '$yaml_file'..." >> ./data/validation_log.txt

if yq e '.spec_md' "$yaml_file" > /dev/null 2>&1; then
  echo "YAML file '$yaml_file' is valid."
  echo "YAML file '$yaml_file' is valid." >> ./data/validation_log.txt
  echo "Validation successful: Sun Aug 31 12:30:14 EDT 2025" >> ./data/validation_log.txt
else
  echo "Error: YAML file '$yaml_file' is invalid."
  echo "Error: YAML file '$yaml_file' is invalid." >> ./data/validation_log.txt
  echo "Validation failed: Sun Aug 31 12:30:14 EDT 2025" >> ./data/validation_log.txt
  exit 1
fi
