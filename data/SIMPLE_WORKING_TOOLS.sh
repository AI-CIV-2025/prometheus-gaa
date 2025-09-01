#!/bin/bash
# SIMPLE WORKING TOOLS - Not placeholders, ACTUAL solutions!
# Created by Claude as example of simplicity > complexity

# 1. System check in ONE LINE (not 50-line script)
check_system() {
    echo "=== Quick System Check ===" && df -h | head -3 && echo && free -h && echo && ps aux | head -5
}

# 2. Log error in ONE LINE (not complex framework)
log_error() {
    echo "[ERROR $(date +%H:%M:%S)] $1" >> gaa.log
}

# 3. Validate YAML in ONE LINE (not elaborate script)
check_yaml() {
    python3 -c "import yaml; yaml.safe_load(open('$1'))" 2>/dev/null && echo "✅ Valid" || echo "❌ Invalid"
}

# 4. Count API calls in ONE LINE (not monitoring framework)
count_api_calls() {
    grep "API call" *.log 2>/dev/null | wc -l
}

# 5. Find all #TASK markers in ONE LINE
find_tasks() {
    grep -r "#TASK" . --include="*.md" --include="*.txt" 2>/dev/null | head -10
}

# USAGE EXAMPLES:
echo "=== SIMPLE WORKING TOOLS DEMO ==="
echo ""
echo "1. System Check:"
check_system
echo ""
echo "2. Log an error:"
log_error "This is a test error"
echo "   Logged to: gaa.log"
echo ""
echo "3. Find tasks:"
find_tasks | head -3
echo ""
echo "LESSON: These 5 one-liners do MORE than your 10 placeholder scripts!"
echo "STOP building frameworks. START solving problems!"