#!/bin/bash
# Script to test system stability by looping core operations

source ./data/common_error_handler.sh

ITERATIONS=5
echo "Starting stability test: Performing ${ITERATIONS} iterations of core operations."
log_message "Starting stability test loop."

for i in $(seq 1 $ITERATIONS); do
  echo "--- Stability Test Iteration $i/$ITERATIONS ---"
  log_message "Starting iteration $i."

  # Operation 1: List files
  ls -la "${EXECUTION_PATH}" > /dev/null
  if [ $? -ne 0 ]; then
      handle_command_failure $? "ls -la ${EXECUTION_PATH}"
  else
      log_message "Iteration $i: File listing successful."
  fi

  # Operation 2: Create a dummy file (if policy allows touch/echo)
  # Check if touch is allowed
  if grep -q 'touch' <<< "$ALLOWED_COMMANDS"; then
      touch "${EXECUTION_PATH}/stability_test_${i}.tmp"
      if [ $? -ne 0 ]; then
          handle_command_failure $? "touch ${EXECUTION_PATH}/stability_test_${i}.tmp"
      else
          log_message "Iteration $i: Dummy file created."
      fi
  else
      echo "Skipping touch test: 'touch' command not allowed by policy."
  fi

  # Operation 3: Run a simple analysis script (e.g., wc on a log file)
  if [ -f "${EXECUTION_PATH}/gaa_system.log" ]; then
      wc -l "${EXECUTION_PATH}/gaa_system.log" > /dev/null
      if [ $? -ne 0 ]; then
          handle_command_failure $? "wc -l ${EXECUTION_PATH}/gaa_system.log"
      else
          log_message "Iteration $i: Log file word count successful."
      fi
  else
      log_message "Iteration $i: Log file not found for wc test."
  fi

  # Simulate a small delay
  sleep 2
  log_message "Finished iteration $i."
done

log_message "Stability test completed."
echo "Stability test finished. Check logs for details."
