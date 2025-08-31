#!/bin/bash

# GAA-5 Automated Backup & Commit Schedule
# Purpose: Regular commits and backups of agent work

set -e

echo "🔄 GAA-5 Automated Backup System"
echo "================================"

# Configuration
BACKUP_DIR="./data/backups"
MAX_BACKUPS=10
COMMIT_MESSAGE_PREFIX="🤖 Auto-backup:"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Function to create timestamped backup
create_backup() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$BACKUP_DIR/gaa5_backup_${timestamp}.tar.gz"
    
    echo "📦 Creating backup: $backup_file"
    tar -czf "$backup_file" \
        --exclude=node_modules \
        --exclude=.git \
        --exclude=data/*.db-* \
        --exclude=data/backups \
        --exclude=*.log \
        src/ site/ data/reports/ data/tools/ data/knowledge/ \
        package.json exec_policy.json 2>/dev/null || true
    
    echo "✅ Backup created: $(du -h "$backup_file" | cut -f1)"
    
    # Clean old backups (keep only MAX_BACKUPS most recent)
    ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -f 2>/dev/null || true
}

# Function to commit current state
commit_current_state() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local stats=$(git diff --shortstat 2>/dev/null || echo "No changes")
    
    if [ -n "$(git status --porcelain)" ]; then
        echo "📝 Changes detected, creating commit..."
        
        # Add all changes except ignored files
        git add -A
        
        # Generate commit message with statistics
        local files_changed=$(git diff --cached --numstat | wc -l)
        local message="$COMMIT_MESSAGE_PREFIX $timestamp

- Files changed: $files_changed
- Agent loops completed: $(sqlite3 data/gaa.db "SELECT COUNT(*) FROM loops" 2>/dev/null || echo "unknown")
- Reports generated: $(find data/reports -name "*.md" 2>/dev/null | wc -l)
- Tools created: $(find data/tools -name "*.sh" 2>/dev/null | wc -l)
- Knowledge articles: $(find data/knowledge -name "*.md" 2>/dev/null | wc -l)

Automated backup of agent progress and artifacts."
        
        git commit -m "$message" || echo "⚠️ Commit failed"
        
        # Push to remote if available
        if git remote get-url origin &>/dev/null; then
            echo "⬆️ Pushing to remote..."
            git push origin main || echo "⚠️ Push failed - will retry next cycle"
        fi
        
        echo "✅ Commit created and pushed"
    else
        echo "✅ No changes to commit"
    fi
}

# Function to run continuous backup loop
run_continuous() {
    local interval=${1:-3600}  # Default: 1 hour
    
    echo "🔄 Starting continuous backup (every $interval seconds)"
    echo "Press Ctrl+C to stop"
    
    while true; do
        echo ""
        echo "⏰ Backup cycle started at $(date)"
        
        create_backup
        commit_current_state
        
        echo "💤 Sleeping for $interval seconds..."
        sleep "$interval"
    done
}

# Function to setup cron job
setup_cron() {
    local script_path=$(realpath "$0")
    local cron_entry="0 * * * * cd $(pwd) && $script_path once >> /tmp/gaa5_backup.log 2>&1"
    
    echo "📅 Setting up hourly cron job..."
    
    # Check if cron entry already exists
    if crontab -l 2>/dev/null | grep -q "gaa5_backup"; then
        echo "✅ Cron job already exists"
    else
        # Add cron entry
        (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
        echo "✅ Cron job added: Hourly backups"
        echo "   View with: crontab -l"
        echo "   Remove with: crontab -e (and delete the line)"
    fi
}

# Main script logic
case "${1:-}" in
    once)
        create_backup
        commit_current_state
        ;;
    continuous)
        run_continuous "${2:-3600}"
        ;;
    cron)
        setup_cron
        ;;
    *)
        echo "Usage: $0 {once|continuous [interval]|cron}"
        echo ""
        echo "Options:"
        echo "  once       - Run backup and commit once"
        echo "  continuous - Run continuously with interval (default: 3600s)"
        echo "  cron       - Setup hourly cron job"
        echo ""
        echo "Examples:"
        echo "  $0 once                  # Single backup"
        echo "  $0 continuous            # Every hour"
        echo "  $0 continuous 1800       # Every 30 minutes"
        echo "  $0 cron                  # Setup automatic hourly backups"
        ;;
esac