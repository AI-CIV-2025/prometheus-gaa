# Knowledge Base Entry: Policy - Command Substitution Restrictions

## 1. Overview
This document clarifies the policy regarding command substitution within the `bash:` execution block. Direct assignment of variables using command substitution (e.g., `VAR=$(command)`) at the top-level of the `bash:` block is strictly prohibited by the execution policy. This restriction is in place to enhance security, ensure predictable execution, and prevent unintended command injection.

## 2. The Restricted Pattern
The following pattern is **NOT ALLOWED** in the `bash:` block:
\`\`\`bash
REPORT_FILENAME="./data/reports/report_$(date +%Y%m%d).md"
cat << 'EOF_REPORT' > "$REPORT_FILENAME"
# Report Content
EOF_REPORT
\`\`\`
Similarly, creating script files with dynamic names or content via top-level variable assignment is also disallowed:
\`\`\`bash
SCRIPT_NAME="./data/tools/script_$(date +%H%M%S).sh"
cat << 'EOF_SCRIPT' > "$SCRIPT_NAME"
#!/bin/bash
echo "Hello"
EOF_SCRIPT
\`\`\`

## 3. Reason for Restriction
The policy's primary goal is to maintain a high level of control and predictability over executed commands. Direct command substitution in the `bash:` block can obscure the exact command being run prior to execution, making policy enforcement complex and potentially leading to security vulnerabilities.

## 4. Approved Pattern: In-Heredoc Dynamic Generation
To achieve dynamic filenames or content generation, all command substitution **MUST** occur within the multi-line `cat << EOF` block. This ensures that the entire command (including dynamic parts) is evaluated within the context of the shell that `cat` invokes, rather than at the top level of the `bash:` block.

**Example of Approved Filename Generation:**
\`\`\`bash
cat << 'EOF_REPORT' > "./data/reports/report_$(date +%Y%m%d_%H%M%S).md"
# Dynamic Report Content
Current time: $(date)
EOF_REPORT
\`\`\`

**Example of Approved Script Content Generation:**
\`\`\`bash
cat << 'EOF_SCRIPT' > "./data/tools/dynamic_script_$(date +%Y%m%d_%H%M%S).sh"
#!/bin/bash
echo "Script executed at: $(date)"
ls -la ./data/
EOF_SCRIPT
chmod +x "./data/tools/dynamic_script_$(date +%Y%m%d_%H%M%S).sh"
\`\`\`
*Note: The `chmod +x` command must reference the exact same filename string as used in the `cat` command.*

## 5. Key Takeaways
- **Avoid:** `VAR=$(command)` at the top level of `bash:`
- **Use:** `> "./path/to/file_$(command).ext"` directly within `cat << EOF`
- All dynamic content, including parts of filenames, must be enclosed within the heredoc's redirection target or its body.

Adhering to this policy ensures compliance and maintains the integrity of the execution environment.
