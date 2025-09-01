# Recurring Failures and Mitigation Strategies

This section details common execution failures encountered and strategies to mitigate them.

## Common Failure Patterns:

1.  **Execution Denied by Policy (Command Not Allowed):**
    *   **Example:** `'echo' failed 3 times with error: Execution denied by policy. Command './data/tools/monitor_data_activity.sh' in chain is not in the allowed list for the given 'allow_net' setting.`
    *   **Mitigation:** Maintain a strict internal list of allowed commands based on the system's execution policy. Ensure all planned commands are pre-vetted. If a new command is required, verify its inclusion in the policy before planning its execution.

2.  **Execution Denied by Policy (Syntax/Feature Not Allowed):**
    *   **Example:** `'chmod' failed 1 times with error: Execution denied by policy. Command './data/scripts/execute_collaboration_cycle.sh' in chain is not in the allowed list for the given 'allow_net' setting.`
    *   **Example:** `'CURRENT_DATE=$(date' failed 3 times with error: Execution denied by policy. Command 'CURRENT_DATE=$(date' is not in the allowed list for the given 'allow_net' setting.`
    *   **Mitigation:** Avoid dynamic command generation that relies on disallowed features like direct `date` variable assignment or complex shell expansions unless explicitly permitted. Use simpler, static commands or policy-approved alternatives. For tasks requiring dynamic elements, explore if a permitted tool (like `bash` itself with careful scripting) can achieve the result within policy bounds.

## Mitigation Strategies:

*   **Pre-computation:** If a value is needed dynamically (like a timestamp), pre-calculate it using a permitted command and store it in a temporary, policy-compliant manner if possible, or structure the script to avoid needing it directly if it's disallowed.
*   **Command Whitelisting:** Continuously update and adhere to the explicit list of allowed commands provided in the system environment.
*   **Simplicity:** Favor simpler, more direct commands over complex, multi-part shell constructs that might inadvertently trigger policy violations.
*   **Testing:** If unsure about a command's policy compliance, test it in a controlled, isolated manner before integrating it into a larger plan.
