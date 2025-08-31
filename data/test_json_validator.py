import subprocess
import os

# Ensure the validator script exists
VALIDATOR_SCRIPT = "./data/json_validator.py"

# Create dummy JSON files for testing
VALID_JSON_CONTENT = '{"name": "test", "value": 123}'
INVALID_JSON_CONTENT = '{"name": "test", "value": 123,' # Missing closing brace

VALID_JSON_FILE = "./data/valid_test.json"
INVALID_JSON_FILE = "./data/invalid_test.json"
NON_EXISTENT_FILE = "./data/non_existent.json"

def create_file(filepath, content):
    with open(filepath, 'w') as f:
        f.write(content)
    print(f"Created test file: {filepath}")

def run_test(test_name, command):
    print(f"\n--- Running Test: {test_name} ---")
    print(f"Command: {' '.join(command)}")
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        print("STDOUT:")
        print(result.stdout)
        print("STDERR:")
        print(result.stderr)
        return True
    except subprocess.CalledProcessError as e:
        print("STDOUT:")
        print(e.stdout)
        print("STDERR:")
        print(e.stderr)
        print(f"Test failed with exit code: {e.returncode}")
        return False
    except FileNotFoundError:
        print(f"Error: Script '{command[0]}' not found. Make sure it's executable and in the PATH or use the full path.")
        return False

if __name__ == "__main__":
    # Create test files
    create_file(VALID_JSON_FILE, VALID_JSON_CONTENT)
    create_file(INVALID_JSON_FILE, INVALID_JSON_CONTENT)

    # Test cases
    print("\n--- Testing JSON Validator ---")

    # Test with a valid JSON file
    test1_command = ["python3", VALIDATOR_SCRIPT, VALID_JSON_FILE]
    run_test("Valid JSON file", test1_command)

    # Test with an invalid JSON file
    test2_command = ["python3", VALIDATOR_SCRIPT, INVALID_JSON_FILE]
    run_test("Invalid JSON file", test2_command)

    # Test with a non-existent file
    test3_command = ["python3", VALIDATOR_SCRIPT, NON_EXISTENT_FILE]
    run_test("Non-existent file", test3_command)

    # Test with multiple files (one valid, one invalid)
    test4_command = ["python3", VALIDATOR_SCRIPT, VALID_JSON_FILE, INVALID_JSON_FILE]
    run_test("Mixed valid and invalid files", test4_command)

    # Clean up test files
    print("\n--- Cleaning up test files ---")
    for f in [VALID_JSON_FILE, INVALID_JSON_FILE]:
        if os.path.exists(f):
            os.remove(f)
            print(f"Removed: {f}")

    print("\nJSON Validator testing complete.")
