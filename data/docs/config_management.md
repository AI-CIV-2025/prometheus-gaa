# Configuration Management Documentation

## Overview
The GAA system utilizes a configuration file (`exec_policy.json`) to define its operational parameters, including allowed commands and network access. This serves as a critical security and control mechanism.

## File: ./data/exec_policy.json

This JSON file dictates the system's execution environment. Key fields include:

- `allowed_commands`: An array of shell commands permitted for execution.
- `allow_net`: A boolean flag (`true`/`false`) indicating whether network access is allowed.

## Example `exec_policy.json` Structure
\`\`\`json
{
  "allowed_commands": [
    "echo", "printf", "cat", "ls", "grep", "find", "date", "chmod", "python3", "python"
  ],
  "allow_net": false
}
\`\`\`

## Importance
Strict adherence to the `exec_policy.json` is crucial for maintaining system security and predictability. Any deviations or unauthorized commands will result in execution denial.

## Related Tools
- `./data/scripts/validate_yaml.py`: A Python script used to validate the integrity and correctness of YAML configuration files. This helps prevent errors caused by malformed configuration.
