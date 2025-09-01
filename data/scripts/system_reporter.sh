#!/bin/bash
#
# system_reporter.sh
# A comprehensive tool to generate system state reports in Markdown format.
# It analyzes the execution environment, data directories, and system policies.
#

# --- Header ---
echo "# System State & Environment Report"
echo "Generated on: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "---"
echo ""

# --- Section 1: Filesystem Overview ---
echo "## 1. Filesystem Overview"
echo "This section provides a summary of the storage and file distribution within the execution path."
echo ""
echo "**Storage Usage for \`${EXECUTION_PATH:-./data}\`:**"
echo "\`\`\`"
df -h . | tail -n 1
echo "\`\`\`"
echo ""
echo "**Directory Tree:**"
echo "\`\`\`"
tree -L 3 ./data || ls -R ./data
echo "\`\`\`"
echo ""

# --- Section 2: Artifact Analysis ---
echo "## 2. Artifact Analysis"
echo "Detailed breakdown of files managed within the \`./data\` directory."
echo ""
echo "| Artifact Type         | Count | Total Size (bytes) |"
echo "|-----------------------|-------|--------------------|"

count_md=$(find ./data -maxdepth 3 -type f -name "*.md" 2>/dev/null | wc -l)
size_md=$(find ./data -maxdepth 3 -type f -name "*.md" -exec stat -c%s {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
echo "| Markdown (.md)        | ${count_md}   | ${size_md}               |"

count_sh=$(find ./data -maxdepth 3 -type f -name "*.sh" 2>/dev/null | wc -l)
size_sh=$(find ./data -maxdepth 3 -type f -name "*.sh" -exec stat -c%s {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
echo "| Scripts (.sh)         | ${count_sh}   | ${size_sh}               |"

count_json=$(find ./data -maxdepth 3 -type f -name "*.json" 2>/dev/null | wc -l)
size_json=$(find ./data -maxdepth 3 -type f -name "*.json" -exec stat -c%s {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
echo "| JSON Configs (.json)  | ${count_json}   | ${size_json}             |"

count_log=$(find ./data -maxdepth 3 -type f -name "*.log" 2>/dev/null | wc -l)
size_log=$(find ./data -maxdepth 3 -type f -name "*.log" -exec stat -c%s {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
echo "| Log Files (.log)      | ${count_log}   | ${size_log}              |"
echo ""

echo "**Recently Modified Files (Top 10):**"
echo "\`\`\`"
ls -lt ./data 2>/dev/null | head -n 11
echo "\`\`\`"
echo ""

# --- Section 3: Execution Policy Analysis ---
echo "## 3. Execution Policy Analysis"
echo "Review of the current execution policy (\`exec_policy.json\`)."
echo ""
if [ -f "exec_policy.json" ]; then
  echo "**Network Access:**"
  if grep -q '"allow_net": true' exec_policy.json; then
    echo "- Status: **ENABLED**"
  else
    echo "- Status: **DISABLED**"
  fi
  echo ""
  echo "**Allowed Command Categories (Sample):**"
  echo "- File Operations: $(jq -r '.allowed_commands[] | select(test("ls|cat|mkdir|cp|mv|rm"))' exec_policy.json | wc -l) commands"
  echo "- Text Processing: $(jq -r '.allowed_commands[] | select(test("grep|sed|awk|sort|uniq"))' exec_policy.json | wc -l) commands"
  echo "- System Inspection: $(jq -r '.allowed_commands[] | select(test("ps|df|du|uname|date"))' exec_policy.json | wc -l) commands"
  echo "- Networking: $(jq -r '.allowed_commands[] | select(test("curl|wget|ping|dig"))' exec_policy.json | wc -l) commands"
else
  echo "Execution policy file \`exec_policy.json\` not found."
fi
echo ""

# --- Section 4: Report Conclusion ---
echo "## 4. Conclusion & Recommendations"
echo "This report provides a snapshot of the system's current state. The environment is active, with a growing number of artifacts."
echo ""
echo "**Key Insights:**"
echo "1. The directory structure is organized for tools, knowledge, and reports, facilitating structured growth."
echo "2. Artifact generation is consistent, indicating ongoing tasks and analysis."
echo "3. The execution policy provides a robust set of tools for file manipulation, system analysis, and scripting."
echo ""
echo "**Recommendations:**"
echo "- **Automate Reporting:** Schedule this script to run periodically to track changes over time."
echo "- **Expand Knowledge Base:** Continue documenting new tools and key findings to build a comprehensive reference library."
echo "- **Monitor Storage:** Keep an eye on the storage usage as more reports and artifacts are generated."
