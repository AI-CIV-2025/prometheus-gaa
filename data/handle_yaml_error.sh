#!/bin/bash

# Function to handle errors during YAML parsing
handle_yaml_error() {
  local script_name="$1"
  local error_message="$2"
  local timestamp=$(date +%Y-%m-%d_%H-%M-%S)

  echo "ERROR: YAML parsing failed in $script_name at $timestamp"
  echo "Error Message: $error_message"
  echo "Script: $script_name" >> ./data/error_log.txt
  echo "Error Message: $error_message" >> ./data/error_log.txt
  echo "Time: $timestamp" >> ./data/error_log.txt
  echo "----------------------------------------" >> ./data/error_log.txt
}
