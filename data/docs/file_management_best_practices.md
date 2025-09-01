# Knowledge Base: File Management Best Practices for the Execution Environment

## 1. Introduction
Effective file management is crucial for maintaining a clean, organized, and efficient execution environment. This document outlines best practices for structuring, naming, and maintaining files within the designated execution path (${EXECUTION_PATH:-./data}). Adhering to these guidelines will improve navigability, reduce clutter, and enhance system understanding for both automated processes and human review.

## 2. Directory Structure Guidelines
A consistent and logical directory structure is the cornerstone of good file management.
-   **Root Execution Path (`./data`)**: This is the primary working directory for all system operations and artifact generation.
-   **`./data/reports/`**: Dedicated to all generated analysis reports, diagnostic outputs, and summary documents.
    -   *Naming Convention*: `type_descriptor_YYYYMMDD_HHMMSS.md` or `.txt` (e.g., `system_diagnostic_20231027_143000.md`).
-   **`./data/tools/`**: Contains all executable scripts, utility programs, and custom helper functions developed for system maintenance or specific tasks.
    -   *Naming Convention*: `purpose_action.sh` (e.g., `monitor_data_dir.sh`, `cleanup_old_logs.sh`). Ensure scripts are executable (`chmod +x`).
-   **`./data/knowledge/`**: Stores documentation, knowledge base entries, operational guides, and architectural notes.
    -   *Naming Convention*: `topic_overview.md` (e.g., `file_management_best_practices.md`, `policy_interpretation.md`).
-   **`./data/logs/`**: (Optional, if applicable) For system-generated logs, errors, or verbose output from long-running processes.
    -   *Naming Convention*: `process_name_YYYYMMDD.log`.
-   **`./data/temp/`**: (Optional, if applicable) For temporary files that can be safely deleted after use. Implement a cleanup routine for this directory.

## 3. File Naming Conventions
Consistent naming facilitates easy identification and retrieval of files.
-   **Descriptive Names**: File names should clearly indicate their content or purpose.
    -   *Good*: `system_status_report_20231027.md`
    -   *Bad*: `report1.md`
-   **Date/Time Stamps**: For reports, logs, and snapshots, include a date and/or time stamp in `YYYYMMDD_HHMMSS` format to ensure uniqueness and chronological order.
    -   *Example*: `analysis_summary_20231027_143500.json`
-   **Lowercase and Hyphens**: Use lowercase letters and hyphens (`-`) for word separation. Avoid spaces or special characters that can cause issues in shell commands.
    -   *Good*: `network-config-backup.txt`
    -   *Bad*: `Network Config Backup.txt`

## 4. Documentation and Metadata
-   **Self-Documenting Scripts**: Include comments within scripts to explain complex logic, functions, and parameters. Provide a brief header with author, date, and purpose.
-   **Report Headers**: All reports should begin with a clear title, generation date, and an executive summary.
-   **Knowledge Base Entries**: Each KB entry should have a clear title, introduction, detailed sections, and a summary or recommendations.

## 5. Maintenance and Cleanup
Regular maintenance prevents the accumulation of outdated or redundant files.
-   **Automated Cleanup**: Develop and deploy scripts (e.g., in `./data/tools/`) to periodically remove old logs, temporary files, or archive reports older than a defined retention period.
-   **Version Control**: While not explicitly implemented here, consider manual versioning for critical documents by appending version numbers (e.g., `proposal_v1.md`, `proposal_v2.md`).
-   **Regular Review**: Periodically review the contents of the `data` directory to identify and address any organizational inconsistencies.

## 6. Security Considerations
-   **Permissions**: Ensure scripts and sensitive files have appropriate file permissions (e.g., scripts `chmod +x`, sensitive data `chmod 600`).
-   **No Sensitive Data in Names**: Avoid putting sensitive information directly into file names.

By adhering to these best practices, the system's operational efficiency and the clarity of its outputs will be significantly enhanced.
