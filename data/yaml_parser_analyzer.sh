#!/bin/bash
# Script to analyze potential YAML parsing issues in configuration files

echo "=== YAML Parser Analyzer ==="
echo "Analyzing YAML files in ${EXECUTION_PATH}..."
echo ""

# Find all YAML files in the execution path
yaml_files=$(find "${EXECUTION_PATH}" -maxdepth 1 -name "*.yaml" -o -name "*.yml")

if [ -z "$yaml_files" ]; then
  echo "No YAML files found in ${EXECUTION_PATH}."
  exit 0
fi

echo "Found YAML files:"
echo "$yaml_files"
echo ""

# Basic check: Ensure files exist and are readable
for file in $yaml_files; do
  if [ ! -r "$file" ]; then
    echo "Error: Cannot read file '$file'. Skipping."
    continue
  fi

  echo "--- Analyzing: $file ---"

  # Check for common YAML syntax errors (e.g., incorrect indentation)
  # Using 'yamllint' if available, otherwise a simpler check
  if command -v yamllint > /dev/null; then
    echo "Running yamllint..."
    yamllint "$file"
    if [ $? -ne 0 ]; then
      echo "Potential syntax errors found by yamllint. Refer to output above."
    else
      echo "yamllint passed."
    fi
  else
    echo "yamllint not found. Performing basic indentation check..."
    # Simple check for consistent indentation (e.g., 2 spaces)
    if grep -vE '^(#.*)?$|^(\s{2,}|[[:space:]]*$)' "$file"; then
      echo "Potential inconsistent indentation detected. Ensure YAML uses consistent spaces (e.g., 2 spaces per indent level)."
    else
      echo "Basic indentation check passed."
    fi
  fi

  # Check for duplicate keys (a common YAML issue)
  echo "Checking for duplicate keys..."
  if yq eval '.. | select(type == "object") | keys | duplicate(.)' "$file" 2>/dev/null | grep -q 'true'; then
    echo "Duplicate keys found in '$file'. This can lead to unpredictable behavior."
  else
    echo "No duplicate keys detected."
  fi

  echo ""
done

echo "=== Analysis Complete ==="
