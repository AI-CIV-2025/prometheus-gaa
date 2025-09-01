# Knowledge Base Entry: Understanding and Avoiding Policy-Denied Command Patterns

## Date: $(date)

## 1. Introduction
This entry documents a critical lesson learned regarding the system's execution policy. Specifically, it addresses the recurring issue of commands being denied due to the use of a forbidden pattern related to variable assignment and command substitution. Understanding and adhering to this constraint is crucial for successful plan execution.

## 2. The Problem: Forbidden Command Substitution Pattern
The execution policy explicitly disallows a specific pattern where the output of a command is directly assigned to a shell variable using the `$(command)` syntax. This pattern, while common in standard shell scripting, is considered a security risk within the sandboxed environment and is therefore prohibited.

**Example of a forbidden conceptual pattern (do NOT use literally in commands):**
