#!/bin/bash
# Error handling function
error_exit() {
  echo "ERROR: $1" >&2
  exit 1
}

# Example usage
# command_that_might_fail || error_exit "Command failed"
