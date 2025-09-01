# Knowledge Base Entry: Safe Command Substitution Practices

## 1. Introduction
This document serves as a critical guide for understanding and correctly applying command substitution within the agent's execution environment. It specifically addresses recurring policy rejections related to variable assignment using command substitution and provides compliant alternatives. Adhering to these guidelines is essential for preventing execution failures and ensuring the agent's continuous operation.

## 2. What is Command Substitution?
Command substitution allows the output of a shell command to be used as part of another command or assigned to a variable. The two primary syntaxes are:
*   \`\$(command)\`: The modern and recommended syntax.
*   \`\`\`command\`\`\` (backticks): An older syntax, generally less preferred due to nesting difficulties.

For example, \`echo "Current date: $(date)"\` would print "Current date: [current date]".

## 3. The Forbidden Pattern: Direct Variable Assignment at the Policy Level
A consistent source of execution failures has been the attempt to assign the output of a command to a variable *directly within the agent's `bash:` block* using the `VAR=$(command)` syntax. The policy parser
