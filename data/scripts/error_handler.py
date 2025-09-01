import logging
import sys

def setup_logging(log_level=logging.INFO):
    logging.basicConfig(level=log_level, 
                        format='%(asctime)s - %(levelname)s - %(message)s')

def handle_yaml_error(error_message, filename=None):
    log_message = f"YAML Parsing Error"
    if filename:
        log_message += f" in file '{filename}'"
    log_message += f": {error_message}"
    logging.error(log_message)
    # Optionally, re-raise or exit if critical
    # sys.exit(f"Fatal YAML Error: {error_message}")

def handle_file_error(error_message, filename=None):
    log_message = f"File Operation Error"
    if filename:
        log_message += f" for file '{filename}'"
    log_message += f": {error_message}"
    logging.error(log_message)
    
# Example of a more generic handler
def handle_general_error(error_message, context="General"):
    logging.error(f"[{context}] {error_message}")

if __name__ == "__main__":
    setup_logging()
    handle_yaml_error("Invalid syntax at line 5", "config.yaml")
    handle_file_error("Permission denied", "data.db")
    handle_general_error("Unexpected condition", "MainLoop")
