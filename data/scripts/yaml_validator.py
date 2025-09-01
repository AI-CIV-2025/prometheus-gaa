import yaml
import sys

def validate_yaml(filename):
  try:
    with open(filename, 'r') as f:
      yaml.safe_load(f)
    print(f"{filename}: OK")
    return True
  except yaml.YAMLError as e:
    print(f"{filename}: ERROR - {e}")
    return False

if __name__ == "__main__":
  if len(sys.argv) > 1:
    filename = sys.argv[1]
    validate_yaml(filename)
  else:
    print("Usage: python yaml_validator.py <filename>")
