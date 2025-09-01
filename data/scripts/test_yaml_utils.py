import unittest
import os
import sys

# Add the scripts directory to the Python path
sys.path.insert(0, './data/scripts')

from validate_yaml import validate_yaml_file
from error_handler import setup_logging, handle_yaml_error, handle_file_error

# Ensure the data/configs directory exists
os.makedirs('./data/configs', exist_ok=True)

VALID_YAML_PATH = './data/configs/test_valid.yaml'
INVALID_YAML_PATH = './data/configs/test_invalid.yaml'
NONEXISTENT_PATH = './data/configs/nonexistent.yaml'

class TestYamlUtils(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        # Create dummy valid YAML file
        with open(VALID_YAML_PATH, 'w') as f:
            f.write("key: value\nlist:\n  - item1\n  - item2\n")
        
        # Create dummy invalid YAML file
        with open(INVALID_YAML_PATH, 'w') as f:
            f.write("key: value\nlist:\n item1:\n  subitem: value\n") # Incorrect indentation

        # Setup logging for error handler tests
        setup_logging()

    @classmethod
    def tearDownClass(cls):
        # Clean up dummy files
        if os.path.exists(VALID_YAML_PATH):
            os.remove(VALID_YAML_PATH)
        if os.path.exists(INVALID_YAML_PATH):
            os.remove(INVALID_YAML_PATH)

    def test_validate_valid_yaml(self):
        self.assertTrue(validate_yaml_file(VALID_YAML_PATH))

    def test_validate_invalid_yaml(self):
        # We expect validate_yaml_file to return False for invalid YAML
        self.assertFalse(validate_yaml_file(INVALID_YAML_PATH))

    def test_validate_nonexistent_file(self):
        # We expect validate_yaml_file to return False for nonexistent files
        self.assertFalse(validate_yaml_file(NONEXISTENT_PATH))

    def test_handle_yaml_error_logs(self):
        # Mocking sys.stderr to capture output, but logging module handles stderr by default
        # For a more robust test, we'd capture logger output directly
        # This test primarily checks if the function runs without crashing and implies logging
        try:
            handle_yaml_error("Sample error message", "test.yaml")
            # If no exception is raised, we consider it passed for this basic check
            self.assertTrue(True) 
        except Exception:
            self.fail("handle_yaml_error raised an unexpected exception.")

    def test_handle_file_error_logs(self):
        try:
            handle_file_error("File access error", "data.file")
            self.assertTrue(True)
        except Exception:
            self.fail("handle_file_error raised an unexpected exception.")

if __name__ == '__main__':
    unittest.main()
