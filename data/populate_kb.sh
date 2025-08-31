#!/bin/bash
echo "Populating initial Knowledge Base entries..."

# Ensure data directory exists
mkdir -p ./data

# Add entry for analyze_code.py failure
cat << KB_ENTRY > ./data/kb_entry_analyze_code_failure.md
# Incident: analyze_code.py execution failure

**Date:** 2025-08-31T13:14:43+00:00
**Incident Type:** Execution Failure
**Component:** Code Analysis Script
**Severity:** High
**Root Cause:** Script 'analyze_code.py' not found at expected path.
**Lessons Learned:** Always verify the existence and accessibility of required scripts before attempting execution. Implement pre-execution checks or integrate script provisioning into the workflow.
**Action Items:**
1. Develop a script verification function.
2. Update workflow orchestration to include script existence checks.
**Tags:** execution, failure, script, python, verification
KB_ENTRY
echo "Created: ./data/kb_entry_analyze_code_failure.md"

# Add entry for incomplete plan lesson
cat << KB_ENTRY > ./data/kb_entry_incomplete_plan.md
# Incident: Incomplete Plan Submission

**Date:** 2025-08-31T13:13:45+00:00
**Incident Type:** Workflow Incompleteness
**Component:** Planning & Execution
**Severity:** Medium
**Root Cause:** Submitted plan did not address all outlined components (e.g., workflow execution guide, incident response plan).
**Lessons Learned:** Ensure all requirements and sub-tasks within a plan are fully addressed before submission. Thoroughly review the scope of each task.
**Action Items:**
1. Implement a checklist for plan comprehensiveness.
2. Enhance review process for generated plans.
**Tags:** planning, completeness, documentation, workflow
KB_ENTRY
echo "Created: ./data/kb_entry_incomplete_plan.md"

# Add entry for policy violation - arbitrary bash
cat << KB_ENTRY > ./data/kb_entry_policy_violation_bash.md
# Incident: Policy Violation - Arbitrary Bash Execution

**Date:** <Current Date/Time>
**Incident Type:** Policy Violation
**Component:** Workflow Orchestration
**Severity:** Critical
**Root Cause:** Attempted to execute arbitrary bash commands without proper sandboxing or validation, violating execution policy.
**Lessons Learned:** Avoid direct execution of unvalidated external commands. Utilize a secure execution layer, command whitelisting, or parameterized commands.
**Action Items:**
1. Implement a secure command execution wrapper.
2. Define and enforce a strict command whitelist.
**Tags:** policy, security, bash, execution, workflow, sandboxing
KB_ENTRY
echo "Created: ./data/kb_entry_policy_violation_bash.md"

echo "Initial Knowledge Base entries populated."
