#!/bin/bash

echo "--- Basic GAA System Test ---"
echo "Date: $(date)"
echo ""

# Check if core directories exist
echo "Checking core directories..."
dirs_to_check=("scripts" "configs" "docs" "logs" "tests" "src")
for dir in "${dirs_to_check[@]}"; do
    if [ -d "./data/$dir" ]; then
        echo "  [PASS] ./data/$dir exists."
    else
        echo "  [FAIL] ./data/$dir is MISSING."
        exit 1
    fi
done

# Check if essential scripts exist and are executable
echo "Checking essential scripts..."
scripts_to_check=("./data/scripts/validate_yaml.sh" "./data/scripts/log_error.sh" "./data/scripts/check_system_status.sh")
for script in "${scripts_to_check[@]}"; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "  [PASS] $script exists and is executable."
    else
        echo "  [FAIL] $script is MISSING or not executable."
        exit 1
    fi
done

# Execute a key script and check its output indirectly
echo "Testing log_error.sh via basic_system_test.sh..."
./data/scripts/log_error.sh "System test log entry" "basic_system_test"
if [ -f "./data/logs/system_errors.log" ] && grep -q "System test log entry" "./data/logs/system_errors.log"; then
    echo "  [PASS] log_error.sh produced expected log entry."
else
    echo "  [FAIL] log_error.sh did not produce expected log entry."
    exit 1
fi

echo ""
echo "--- Basic System Test PASSED ---"
exit 0
