#!/bin/bash
echo "=== GAA System Component Validation ==="
echo "Running validation on: $(date)"
echo ""

# Validate README.md
echo "Validating README.md..."
if [ -f "${EXECUTION_PATH}/README.md" ]; then
    echo "  - README.md exists."
    if grep -q "GAA System Documentation" "${EXECUTION_PATH}/README.md"; then
        echo "  - README.md content seems valid."
    else
        echo "  - WARNING: README.md content might be incorrect."
    fi
else
    echo "  - ERROR: README.md not found."
    exit 1
fi
echo ""

# Validate list_docs.sh
echo "Validating list_docs.sh..."
if [ -f "${EXECUTION_PATH}/list_docs.sh" ]; then
    echo "  - list_docs.sh exists."
    if [ -x "${EXECUTION_PATH}/list_docs.sh" ]; then
        echo "  - list_docs.sh is executable."
        # Execute and capture output for basic check
        if "${EXECUTION_PATH}/list_docs.sh" > /dev/null 2>&1; then
            echo "  - list_docs.sh executed successfully (basic check)."
        else
            echo "  - WARNING: list_docs.sh execution failed."
        fi
    else
        echo "  - ERROR: list_docs.sh is not executable."
        exit 1
    fi
else
    echo "  - ERROR: list_docs.sh not found."
    exit 1
fi
echo ""

# Add more component validations as needed
# Example: Validate a placeholder config file if one were created
# echo "Validating config.json..."
# if [ -f "${EXECUTION_PATH}/config.json" ]; then
#     echo "  - config.json exists."
#     if jq -e . "${EXECUTION_PATH}/config.json" > /dev/null 2>&1; then
#         echo "  - config.json is valid JSON."
#     else
#         echo "  - ERROR: config.json is not valid JSON."
#         exit 1
#     fi
# else
#     echo "  - INFO: config.json not found (expected if not yet created)."
# fi
# echo ""

echo "Component validation complete."
exit 0
