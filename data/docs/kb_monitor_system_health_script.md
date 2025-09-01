# Knowledge Base Entry: monitor_system_health.sh

## 1. Purpose
The `monitor_system_health.sh` script is designed to provide a basic, automated check of the system's health and resource utilization. It logs key metrics and alerts on potential issues, aiding in proactive system management.

## 2. Features
- **Disk Usage Monitoring:** Checks the percentage of disk space used and flags if it exceeds a predefined threshold (85%).
- **File Count Monitoring:** Tracks the number of log files (`.log`) and report files (`.md`) in their respective directories, alerting if the count exceeds specified limits (`MAX_LOG_FILES`, `MAX_REPORT_FILES`). This helps manage storage and identify potential runaway processes creating excessive files.
- **System Uptime Indicator:** Notes if the system has recently started, which might be relevant for initial performance observations.
- **Error Log Detection:** Scans recent log files for critical errors (keywords "ERROR" or "CRITICAL") and logs any findings.
- **Centralized Logging:** All checks and their outcomes are logged to `./data/health_check.log` for review.
- **Directory Management:** Ensures that necessary log and report directories exist before performing checks.

## 3. Usage
To execute the script:
\`\`\`bash
./data/tools/monitor_system_health.sh
\`\`\`

The output will be displayed on the console and also appended to `./data/health_check.log`.

## 4. Configuration
The script can be configured by modifying the variables at the beginning of the file:
- \`LOG_DIR\`: Path to the directory for log files.
- \`REPORTS_DIR\`: Path to the directory for report files.
- \`HEALTH_CHECK_FILE\`: Path to the main health check log file.
- \`MAX_LOG_FILES\`: Maximum allowed number of log files.
- \`MAX_REPORT_FILES\`: Maximum allowed number of report files.

## 5. Best Practices
- **Regular Execution:** Schedule this script to run periodically (e.g., using cron or a task scheduler) to maintain ongoing system awareness.
- **Threshold Adjustment:** Adjust the \`DISK_USAGE\` threshold and file count limits based on specific system requirements and acceptable risk levels.
- **Log Rotation Strategy:** Implement a robust log rotation policy for \`$LOG_DIR\` to prevent excessive disk space consumption. The script includes commented-out examples for \`find ... -delete\` which should be used with extreme caution and thorough testing.
- **Error Handling:** Enhance error checking within the script itself to capture any failures during the execution of the monitoring tasks.

## 6. Dependencies
- Standard Unix/Linux utilities (bash, date, df, ls, wc, grep, awk, sed, mkdir, echo, tail).
- Access to the file system to read/write logs and reports.

## 7. Version History
- **v1.0 (Initial Release):** Basic health checks for disk, file counts, and log errors.
