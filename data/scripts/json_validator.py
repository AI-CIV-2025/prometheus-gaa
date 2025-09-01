import json
import sys
import os

def validate_json(file_path):
    """Validates if the content of a given file is valid JSON."""
    if not os.path.exists(file_path):
        print(f"Error: File not found at '{file_path}'")
        return False
    
    try:
        with open(file_path, 'r') as f:
            json.load(f)
        print(f"Success: '{file_path}' is valid JSON.")
        return True
    except json.JSONDecodeError as e:
        print(f"Error: '{file_path}' is not valid JSON. Details: {e}")
        return False
    except Exception as e:
        print(f"An unexpected error occurred while processing '{file_path}': {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python json_validator.py <file_path1> [<file_path2> ...]")
        sys.exit(1)
    
    all_valid = True
    for i in range(1, len(sys.argv)):
        if not validate_json(sys.argv[i]):
            all_valid = False
    
    if not all_valid:
        sys.exit(1)
    else:
        sys.exit(0)
