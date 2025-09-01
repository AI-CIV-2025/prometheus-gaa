#!/bin/bash

# --- GAA YAML Validator ---
# This script validates YAML file syntax. It relies on 'yq' if available,
# otherwise it performs basic checks for common YAML structures.

VALIDATE_LOG="./logs/validation.log"
mkdir -p ./logs

log_validation() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$VALIDATE_LOG"
    echo "[$timestamp] $message"
}

if command -v yq &> /dev/null; then
    log_validation "'yq' command found. Using yq for validation."
    # Validate all .yaml and .yml files in the current directory and subdirectories
    find . -name "*.yaml" -o -name "*.yml" | while read -r filepath; do
        log_validation "Validating: $filepath"
        if yq eval '.' "$filepath" > /dev/null 2>&1; then
            log_validation "SUCCESS: $filepath is valid YAML."
        else
            log_validation "ERROR: $filepath is NOT valid YAML. yq reported an error."
            # Optionally, capture the specific yq error message
            yq eval '.' "$filepath" > /dev/null
        fi
    done
else
    log_validation "'yq' command not found. Performing basic YAML syntax checks."
    log_validation "NOTE: Basic checks are limited and may not catch all errors."
    # Basic check: Look for lines starting with '-' or ':' followed by a space, common in YAML.
    # This is a very rudimentary check.
    find . -name "*.yaml" -o -name "*.yml" | while read -r filepath; do
        log_validation "Performing basic check on: $filepath"
        if grep -qE '^\s*(-|:)\s+' "$filepath"; then
            log_validation "BASIC CHECK PASSED: $filepath contains common YAML patterns."
        else
            log_validation "BASIC CHECK FAILED: $filepath does not appear to contain typical YAML structures. Review manually."
        fi
    done
fi

log_validation "YAML validation process finished."
# #TASK Add support for validating JSON files as well, potentially using 'jq'.
# #TASK Implement a mechanism to automatically apply fixes for common YAML/JSON errors if possible.
