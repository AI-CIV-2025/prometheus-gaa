# Knowledge Base: Understanding the Execution Environment

## 1. Introduction
This document provides a comprehensive guide to the operational environment of the AI planning assistant. Understanding these parameters is crucial for effective development, debugging, and ensuring compliance with system policies. It covers key aspects such as the designated execution path, allowed commands, and best practices for creating robust and compliant plans.

## 2. The Execution Path: `EXECUTION_PATH`
The `EXECUTION_PATH` variable defines the mandatory base directory for all file operations.
- **Current Value**: `${EXECUTION_PATH:-./data}`
- **Requirement**: All file creation, modification, or access *must* occur within this directory. Using paths outside of `EXECUTION_PATH` (e.g., `/app/data` or `/tmp`) will result in execution failure due to security policies.
- **Example**: To create a file named `my_file.txt`, use `echo "content" > ./data/my_file.txt`.

## 3. Allowed Commands Whitelist
The system operates under a strict command whitelist to ensure security and stability. Only commands explicitly listed in the `System Execution Policy` are permitted. Any attempt to use an unlisted command will be rejected.

**Key Categories of Allowed Commands:**
- **File System Operations**: `ls`, `cat`, `echo`, `mkdir`, `touch`, `cp`, `mv`, `rm` (with caution), `grep`, `find`, `df`, `du`, `wc`.
- **Basic Utilities**: `date`, `uptime`, `uname`, `hostname`, `whoami`, `id`.
- **Text Processing**: `sed`, `awk`, `cut`, `paste`, `sort`, `uniq`, `head`, `tail`.
- **Scripting Constructs**: `bash`, `sh`, `if`, `then`, `else`, `fi`, `for`, `while`, `function`, `return`, `exit`.
- **Networking (Conditional)**: `curl`, `wget`, `ping`, `nc` (only when `allow_net: true`).
- **Development Tools**: `git`, `python`, `node`, `npm`, `pip`, `make`, `gcc` (if installed).

**Important Note on Command Execution**:
Even if a command is whitelisted, its usage within complex constructs (e.g., nested command substitutions `$(...)` or chained commands without proper separation) might be flagged by the policy engine if the risk score exceeds thresholds. It is best practice to:
- **Isolate Complex Operations**: Break down complex command lines.
- **Use Temporary Files**: Gather data into temporary files first, then process or combine them.
- **Simple Heredocs**: Keep `cat << EOF` blocks as simple as possible, avoiding complex logic directly within them.

## 4. Key Directories and Their Purpose
- **`./data/`**: The primary working directory (`EXECUTION_PATH`). All generated data, reports, tools, and knowledge base entries reside here.
- **`./data/reports/`**: Dedicated for storing analytical reports, summaries, and any other generated documentation.
- **`./data/tools/`**: Contains executable scripts and utility programs developed by the system. These tools automate tasks and extend system capabilities.
- **`./data/knowledge/`**: Stores knowledge base articles, guides, and documentation to enhance the system's understanding and provide reference for human operators.
- **`./data/tmp/`**: A temporary directory for intermediate files generated during complex operations, to be cleaned up after use.

## 5. Best Practices for Plan Creation
- **Explicit Paths**: Always use `./data/` for file operations.
- **Modularity**: Break down missions into smaller, distinct steps.
- **Tangible Outputs**: Each step should produce a valuable, tangible output.
- **Policy Awareness**: Verify all commands against the allowed list.
- **Error Handling**: Consider basic error handling (e.g., `2>/dev/null` for suppressing errors from `ls` on non-existent files).
- **Documentation**: Provide clear comments in scripts and comprehensive descriptions in knowledge base entries.
- **Avoid Destructive Commands**: Never use `rm -rf` without extreme caution and explicit need. Avoid `sudo` or any privilege escalation.

By adhering to these guidelines, the AI planning assistant can operate efficiently, securely, and continue to generate high-quality, meaningful outputs.
