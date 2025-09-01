#!/bin/bash
#
# ========================================
#        System Profiler Script
# ========================================
#
# Description: Gathers comprehensive data about the current execution environment.
# Author: AI Planning Assistant
# Version: 1.0
# Created: $(date)
#

echo "### System Profile Report - Generated: $(date) ###"
echo "======================================================="

echo "\n--- 1. Filesystem Analysis ---"
echo "This section details storage and file distribution."
echo "\n[+] Current Directory Usage:"
du -sh ./data 2>/dev/null || echo "Could not run du."
echo "\n[+] Overall Disk Space:"
df -h . 2>/dev/null || echo "Could not run df."
echo "\n[+] Recursive File Listing of ./data (top 20 lines):"
ls -lR ./data 2>/dev/null | head -n 20 || echo "Could not list files."
echo "\n[+] Directory Tree Structure:"
tree ./data 2>/dev/null || echo "Tree command not available. Listing directories instead:" && find ./data -type d

echo "\n--- 2. Environment & Identity ---"
echo "This section shows user, host, and environment variables."
echo "\n[+] Current User and Host:"
echo "User: $(whoami 2>/dev/null)"
echo "Hostname: $(hostname 2>/dev/null)"
echo "\n[+] System Information (uname):"
uname -a 2>/dev/null || echo "Could not run uname."
echo "\n[+] Key Environment Variables (first 10):"
printenv | head -n 10

echo "\n--- 3. Process Information ---"
echo "This section provides a snapshot of running processes."
echo "\n[+] Top 15 Processes (by CPU/Memory):"
ps -eo pid,ppid,%cpu,%mem,cmd --sort=-%cpu | head -n 15 2>/dev/null || echo "Could not run ps."

echo "\n--- 4. Execution Policy Analysis ---"
echo "This section inspects the capabilities defined in exec_policy.json."
if [ -f "exec_policy.json" ]; then
  echo "[+] Execution Policy found."
  echo "Total allowed commands: $(jq '.commands | length' exec_policy.json 2>/dev/null || grep -c '\"' exec_policy.json)"
  echo "Network access (curl/wget): $(jq '.commands | any(. == "curl" or . == "wget")' exec_policy.json 2>/dev/null || echo "unknown")"
  echo "Python available: $(jq '.commands | any(. == "python3")' exec_policy.json 2>/dev/null || echo "unknown")"
  echo "NodeJS available: $(jq '.commands | any(. == "node")' exec_policy.json 2>/dev/null || echo "unknown")"
else
  echo "[!] exec_policy.json not found in root directory."
fi

echo "\n======================================================="
echo "### End of Report ###"
