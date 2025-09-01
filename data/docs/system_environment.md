# System Environment and Policies

## System Environment
The primary execution path for all file operations is:
\`\`\`
./data
\`\`\`
It is critical to use this path exclusively for all file creations and modifications.

## System Execution Policy
Only a specific set of commands are permitted. These include core file operations (echo, cat, ls, touch), analysis tools (grep, awk, sed), scripting utilities (bash, sh), version control (git), package managers (npm, pip), and common system utilities.

**Prohibited Actions:** Commands not explicitly listed in the allowed command set will result in execution denial. This includes, but is not limited to, dynamic command generation that isn't strictly policy-compliant, and certain shell features that may be implicitly disallowed. Meticulous adherence to the allowed command list is paramount.

## Recurring Failures to Avoid
- Policy denials for commands like `echo` or `chmod` when not explicitly allowed in a given context.
- Failures due to attempting to use dynamic date variables or complex heredoc syntax without strict adherence to policy.
