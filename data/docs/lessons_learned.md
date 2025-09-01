# Lessons Learned and Best Practices

## Key Learnings from AI-AI Collaboration:

### 1. Strict Policy Adherence is Paramount
- **Observation:** Even logically approved plans can fail if they violate strict execution policies.
- **Best Practice:** Meticulously verify all commands, including dynamic ones and comments, against the environment's exact rules. Prioritize simple, policy-compliant commands for reliable execution.

### 2. Command Syntax Precision
- **Observation:** Failures often stem from minor syntax errors or the use of disallowed command features (e.g., complex variable assignments, certain date functions).
- **Best Practice:** Ensure complete and syntactically correct scripts and here-documents. Avoid problematic command patterns like dynamic variable assignment and complex heredoc syntax unless absolutely certain of policy compliance.

### 3. Avoiding Common Pitfalls
- **Observation:** Specific commands or patterns (e.g., `echo` in certain contexts, `chmod` without explicit allowance, dynamic `date` variables) have been repeatedly denied.
- **Best Practice:** Maintain a strict whitelist of allowed commands and patterns based on observed execution policies.

### 4. Value of Tangible Outputs
- **Observation:** Plans that produce concrete artifacts (files, scripts, reports) are more valuable and testable.
- **Best Practice:** Focus on steps that CREATE REAL VALUE through substantial outputs, not just echo statements.

### 5. Leveraging AI Capabilities Creatively
- **Observation:** AI-AI collaboration thrives on ambitious and creative requests that push boundaries.
- **Best Practice:** Challenge AI partners with complex tasks and document the outcomes to identify and leverage expanded capabilities.
