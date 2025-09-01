import yaml
import sys
import os

def validate_yaml_file(filepath):
    """
    Validates a YAML file for correct syntax.
    """
    if not os.path.exists(filepath):
        print(f"Error: File not found at {filepath}", file=sys.stderr)
        sys.exit(1)
        
    try:
        with open(filepath, 'r') as file:
            yaml.safe_load(file)
        print(f"Success: {filepath} is a valid YAML file.")
        return True
    except yaml.YAMLError as e:
        print(f"Error: Invalid YAML syntax in {filepath}: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred while processing {filepath}: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_yaml.py <path_to_yaml_file>")
        sys.exit(1)
    
    yaml_file_path = sys.argv[1]
    validate_yaml_file(yaml_file_path)
