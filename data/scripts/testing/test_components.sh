#!/bin/bash
TEST_REPORT="./data/component_test_report.md"

echo "# GAA System Component Test Report" > "${TEST_REPORT}"
echo "Date: $(date)" >> "${TEST_REPORT}"
echo "" >> "${TEST_REPORT}"

# Test 1: Script Catalog Creation
echo "## Test: Script Catalog Creation" >> "${TEST_REPORT}"
if [ -f "./data/script_catalog.md" ]; then
    echo "- ✅ SUCCESS: './data/script_catalog.md' was created." >> "${TEST_REPORT}"
else
    echo "- ❌ FAILURE: './data/script_catalog.md' was not found." >> "${TEST_REPORT}"
fi
echo "" >> "${TEST_REPORT}"

# Test 2: README Creation
echo "## Test: README Creation" >> "${TEST_REPORT}"
if [ -f "./data/README.md" ]; then
    echo "- ✅ SUCCESS: './data/README.md' was created." >> "${TEST_REPORT}"
else
    echo "- ❌ FAILURE: './data/README.md' was not found." >> "${TEST_REPORT}"
fi
echo "" >> "${TEST_REPORT}"

# Test 3: Enhanced Logging Script Creation
echo "## Test: Enhanced Logging Script Creation" >> "${TEST_REPORT}"
if [ -f "./data/scripts/stability/enhanced_logging.sh" ]; then
    echo "- ✅ SUCCESS: './data/scripts/stability/enhanced_logging.sh' was created." >> "${TEST_REPORT}"
    # Basic execution test for logging script
    ./data/scripts/stability/enhanced_logging.sh > /dev/null 2>&1
    if [ -d "./data/logs" ] && [ -f "./data/logs/info.log" ]; then
        echo "- ✅ SUCCESS: Enhanced logging script executed and created log directory/file." >> "${TEST_REPORT}"
    else
        echo "- ⚠️ WARNING: Enhanced logging script executed, but log directory/file not found. Manual check required." >> "${TEST_REPORT}"
    fi
else
    echo "- ❌ FAILURE: './data/scripts/stability/enhanced_logging.sh' was not found." >> "${TEST_REPORT}"
fi
echo "" >> "${TEST_REPORT}"

# Test 4: YAML Validation Script Creation
echo "## Test: YAML Validation Script Creation" >> "${TEST_REPORT}"
if [ -f "./data/scripts/validation/validate_yaml.sh" ]; then
    echo "- ✅ SUCCESS: './data/scripts/validation/validate_yaml.sh' was created." >> "${TEST_REPORT}"
    # Basic execution test for YAML validation script
    ./data/scripts/validation/validate_yaml.sh > /dev/null 2>&1
    if [ -f "./data/config.yaml" ] && [ -f "./data/validation_report.md" ]; then
        echo "- ✅ SUCCESS: YAML validation script executed and created sample config/report." >> "${TEST_REPORT}"
    else
        echo "- ❌ FAILURE: YAML validation script execution failed or did not create expected files." >> "${TEST_REPORT}"
    fi
else
    echo "- ❌ FAILURE: './data/scripts/validation/validate_yaml.sh' was not found." >> "${TEST_REPORT}"
fi
echo "" >> "${TEST_REPORT}"

echo "Component testing script created at ./data/scripts/testing/test_components.sh"
echo "Component test report generated at ./data/component_test_report.md"
