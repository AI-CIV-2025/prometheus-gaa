#!/bin/bash
set -e
POLICY_FILE="exec_policy.json"
if [ -z "$1" ]; then
  echo '{"success":[], "failed":[{"title":"script_error","stderr":"No JSON input provided to run_steps.sh"}], "final_report_md": "Execution failed: No input."}'
  exit 1
fi
STEPS_JSON="$1"
if [ ! -f "$POLICY_FILE" ]; then
  echo "{\"success\":[], \"failed\":[{\"title\":\"script_error\",\"stderr\":\"Execution policy file not found at ${POLICY_FILE}\"}], \"final_report_md\": \"Execution failed: Policy not found.\"}"
  exit 1
fi

# Use system jq explicitly to avoid Node.js module conflicts
JQ_BIN="/usr/local/bin/jq"
if [ ! -x "$JQ_BIN" ]; then
    # Fallback to finding jq in PATH
    JQ_BIN=$(which jq 2>/dev/null)
    if [ -z "$JQ_BIN" ]; then
        echo "{\"success\":[], \"failed\":[{\"title\":\"script_error\",\"stderr\":\"'jq' is not installed. It is required for parsing steps.\"}], \"final_report_md\": \"Execution failed: JQ dependency missing.\"}"
        exit 1
    fi
fi

# Load policy rules
ALLOWED_BINS=$("$JQ_BIN" -r '.allow_bins | .[]' "$POLICY_FILE")
ALLOWED_NET_BINS=$("$JQ_BIN" -r '.allow_net_bins | .[]' "$POLICY_FILE")
DENY_PATTERNS=$("$JQ_BIN" -r '.deny_patterns | .[]' "$POLICY_FILE")

SUCCESS_STEPS=()
FAILED_STEPS=()
REPORT_MD="# Execution Report: $(date -uIs)\n\n"

# Function to check if command contains deny patterns
contains_deny_pattern() {
    local cmd="$1"
    while IFS= read -r pattern; do
        if [[ "$cmd" == *"$pattern"* ]]; then
            echo "true"
            return
        fi
    done <<< "$DENY_PATTERNS"
    echo "false"
}

# Function to validate a single command
validate_command() {
    local cmd="$1"
    local allow_net="$2"
    
    # Trim leading/trailing whitespace
    cmd=$(echo "$cmd" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Extract the first word (command)
    local first_word=$(echo "$cmd" | awk '{print $1}')
    
    # Check against allowed bins
    local is_allowed=false
    for bin in $ALLOWED_BINS; do 
        if [[ "$first_word" == "$bin" ]]; then 
            is_allowed=true
            break
        fi
    done
    
    # Check network commands if allow_net is true
    if [[ "$allow_net" == "true" ]]; then
        for bin in $ALLOWED_NET_BINS; do 
            if [[ "$first_word" == "$bin" ]]; then 
                is_allowed=true
                break
            fi
        done
    else
        # If allow_net is false, network commands are explicitly denied
        for bin in $ALLOWED_NET_BINS; do 
            if [[ "$first_word" == "$bin" ]]; then 
                is_allowed=false
                break
            fi
        done
    fi
    
    echo "$is_allowed"
}

# Parse array length first
NUM_STEPS=$(echo "$STEPS_JSON" | "$JQ_BIN" 'length')
for i in $(seq 0 $((NUM_STEPS - 1))); do
    step=$(echo "$STEPS_JSON" | "$JQ_BIN" -c ".[$i]")
    title=$(echo "$step" | "$JQ_BIN" -r '.title')
    bash_cmd=$(echo "$step" | "$JQ_BIN" -r '.bash')
    timeout_sec=$(echo "$step" | "$JQ_BIN" -r '.timeout_sec // 60')
    allow_net=$(echo "$step" | "$JQ_BIN" -r '.allow_net // false')
    
    # CRITICAL SECURITY CHECK 1: Check for deny patterns first
    if [[ $(contains_deny_pattern "$bash_cmd") == "true" ]]; then
        stderr="Execution denied by policy. Command contains forbidden pattern from deny list."
        step_result=$("$JQ_BIN" -n --arg t "$title" --arg e "$stderr" --arg b "$bash_cmd" '{"title":$t, "exit_code":-1, "stdout":"", "stderr":$e, "bash":$b}')
        FAILED_STEPS+=("$step_result")
        REPORT_MD+="## ❌ FAILED (Policy): $title\n\`\`\`bash\n$bash_cmd\n\`\`\`\n**Error:** $stderr\n\n"
        continue
    fi
    
    # CRITICAL SECURITY CHECK 2: Parse command chain and validate each part
    # HEREDOC FIX: Check if this is a heredoc command first
    if [[ "$bash_cmd" =~ \<\<[[:space:]]*[\'\"]?([A-Za-z_][A-Za-z0-9_]*) ]]; then
        # This is a heredoc - extract just the command line (before heredoc)
        # Get the first line which contains the actual command
        first_line=$(echo "$bash_cmd" | head -1)
        # Extract the main command (before any redirect or heredoc)
        main_cmd=$(echo "$first_line" | sed 's/<<.*//' | sed 's/>.*//' | awk '{print $1}')
        
        # Validate just the main command
        if [[ $(validate_command "$main_cmd" "$allow_net") == "false" ]]; then
            stderr="Execution denied by policy. Command '${main_cmd}' is not in the allowed list for the given 'allow_net' setting."
            step_result=$("$JQ_BIN" -n --arg t "$title" --arg e "$stderr" --arg b "$bash_cmd" '{"title":$t, "exit_code":-1, "stdout":"", "stderr":$e, "bash":$b}')
            FAILED_STEPS+=("$step_result")
            REPORT_MD+="## ❌ FAILED (Policy): $title\n\`\`\`bash\n$bash_cmd\n\`\`\`\n**Error:** $stderr\n\n"
            continue
        fi
        # Heredoc command is valid, skip further parsing
    else
        # Not a heredoc, use original parsing logic for command chains
        # Split by command separators: ; && || |
        temp_cmd="$bash_cmd"
        temp_cmd=$(echo "$temp_cmd" | sed 's/;/\n/g')
        temp_cmd=$(echo "$temp_cmd" | sed 's/&&/\n/g')
        temp_cmd=$(echo "$temp_cmd" | sed 's/||/\n/g')
        temp_cmd=$(echo "$temp_cmd" | sed 's/|/\n/g')
        
        # Check each sub-command
        all_valid=true
        invalid_reason=""
        while IFS= read -r subcmd; do
            # Skip empty lines
            if [[ -z "$subcmd" || "$subcmd" =~ ^[[:space:]]*$ ]]; then
                continue
            fi
            
            # Check if this subcommand is valid
            if [[ $(validate_command "$subcmd" "$allow_net") == "false" ]]; then
                all_valid=false
                first_word=$(echo "$subcmd" | awk '{print $1}')
                invalid_reason="Command '${first_word}' in chain is not in the allowed list for the given 'allow_net' setting."
                break
            fi
        done <<< "$temp_cmd"
        
        # If any subcommand is invalid, reject the whole step
        if [[ "$all_valid" == "false" ]]; then
            stderr="Execution denied by policy. $invalid_reason"
            step_result=$("$JQ_BIN" -n --arg t "$title" --arg e "$stderr" --arg b "$bash_cmd" '{"title":$t, "exit_code":-1, "stdout":"", "stderr":$e, "bash":$b}')
            FAILED_STEPS+=("$step_result")
            REPORT_MD+="## ❌ FAILED (Policy): $title\n\`\`\`bash\n$bash_cmd\n\`\`\`\n**Error:** $stderr\n\n"
            continue
        fi
    fi
    
    # Execute command and capture output
    set +e  # Don't exit on error
    output=$(timeout "$timeout_sec" bash -c "$bash_cmd" 2>&1)
    exit_code=$?
    set -e  # Re-enable exit on error
    
    if [ $exit_code -eq 0 ]; then
        step_result=$("$JQ_BIN" -n --arg t "$title" --arg o "$output" --arg b "$bash_cmd" '{"title":$t, "exit_code":0, "stdout":$o, "stderr":"", "bash":$b}')
        SUCCESS_STEPS+=("$step_result")
        REPORT_MD+="## ✅ SUCCESS: $title\n\`\`\`bash\n$bash_cmd\n\`\`\`\n**Output:**\n\`\`\`\n$output\n\`\`\`\n\n"
    elif [ $exit_code -eq 124 ]; then
        stderr="Command timed out after ${timeout_sec} seconds."
        step_result=$("$JQ_BIN" -n --arg t "$title" --arg e "$stderr" --arg b "$bash_cmd" '{"title":$t, "exit_code":124, "stdout":"", "stderr":$e, "bash":$b}')
        FAILED_STEPS+=("$step_result")
        REPORT_MD+="## ❌ FAILED (Timeout): $title\n\`\`\`bash\n$bash_cmd\n\`\`\`\n**Error:** $stderr\n\n"
    else
        step_result=$("$JQ_BIN" -n --arg t "$title" --arg e "$output" --arg b "$bash_cmd" --argjson c "$exit_code" '{"title":$t, "exit_code":$c, "stdout":"", "stderr":$e, "bash":$b}')
        FAILED_STEPS+=("$step_result")
        REPORT_MD+="## ❌ FAILED (Exit Code $exit_code): $title\n\`\`\`bash\n$bash_cmd\n\`\`\`\n**Error:**\n\`\`\`\n$output\n\`\`\`\n\n"
    fi
done

SUCCESS_JSON=$(IFS=,; echo "${SUCCESS_STEPS[*]}")
FAILED_JSON=$(IFS=,; echo "${FAILED_STEPS[*]}")
FINAL_JSON=$("$JQ_BIN" -n --argjson s "[$SUCCESS_JSON]" --argjson f "[$FAILED_JSON]" --arg r "$REPORT_MD" '{"success": $s, "failed": $f, "final_report_md": $r}')
echo "$FINAL_JSON"