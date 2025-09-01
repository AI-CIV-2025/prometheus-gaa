#!/bin/bash
echo "--- GAA System Self-Test ---"
echo "Timestamp: $(date)"
echo ""

# Check for essential documentation files
echo "Checking for essential documentation files..."
if [ -f "${EXECUTION_PATH}/README.md" ]; then
    echo "  [PASS] README.md found."
else
    echo "  [FAIL] README.md not found. Please ensure documentation is generated."
fi

if [ -f "${EXECUTION_PATH}/working_scripts_documentation.md" ]; then
    echo "  [PASS] working_scripts_documentation.md found."
else
    echo "  [FAIL] working_scripts_documentation.md not found. Please ensure script documentation is generated."
fi

# Check for core executable scripts
echo ""
echo "Checking for core executable scripts..."
if [ -f "${EXECUTION_PATH}/stats.sh" ] && [ -x "${EXECUTION_PATH}/stats.sh" ]; then
    echo "  [PASS] stats.sh is executable."
else
    echo "  [FAIL] stats.sh is missing or not executable. Ensure it's generated correctly."
fi

if [ -f "${EXECUTION_PATH}/self_test.sh" ] && [ -x "${EXECUTION_PATH}/self_test.sh" ]; then
    echo "  [PASS] self_test.sh is executable."
else
    echo "  [FAIL] self_test.sh is missing or not executable. Ensure it's generated correctly."
fi

# Basic command execution test
echo ""
echo "Performing basic command execution test..."
if echo "System command test successful." > /dev/null 2>&1; then
    echo "  [PASS] Basic 'echo' command execution successful."
else
    echo "  [FAIL] Basic 'echo' command execution failed. Check execution policy."
fi

echo ""
echo "--- Self-Test Complete ---"
