# 🔄 GAA-5 Rollback Protocol

**Version**: 1.0  
**Created**: August 31, 2025  
**Purpose**: Safe rollback procedures for GAA-5 testing environment

## 🚨 When to Rollback

Rollback should be considered when:
1. **Critical Bug**: Agents enter infinite error loops
2. **Database Corruption**: SQLite database becomes corrupted
3. **Runaway Execution**: Agents consuming excessive resources
4. **Policy Violation**: Agents attempting unauthorized operations
5. **API Exhaustion**: Rapid depletion of API quota

## 📋 Pre-Rollback Checklist

Before rolling back:
- [ ] Stop the running system (`Ctrl+C` or kill process)
- [ ] Document the issue in `/data/rollback_log.md`
- [ ] Save current logs: `cp /tmp/gaa-*.log ./data/backups/`
- [ ] Create emergency backup: `./backup_schedule.sh once`

## 🔧 Rollback Methods

### Method 1: Git Rollback (Recommended)
```bash
# View recent commits
git log --oneline -10

# Rollback to specific commit (preserves history)
git revert HEAD  # Undo last commit
# OR
git revert <commit-hash>  # Undo specific commit

# Push the revert
git push origin main
```

### Method 2: Hard Reset (Destructive)
```bash
# ⚠️ WARNING: This destroys uncommitted changes!

# Reset to previous commit
git reset --hard HEAD~1
# OR reset to specific commit
git reset --hard <commit-hash>

# Force push (requires force push permissions)
git push --force origin main
```

### Method 3: Backup Restoration
```bash
# List available backups
ls -lah data/backups/

# Choose a backup to restore
BACKUP_FILE="data/backups/gaa5_backup_20250831_120000.tar.gz"

# Create safety backup of current state
tar -czf emergency_backup_$(date +%s).tar.gz src/ site/ data/

# Extract backup (will overwrite current files)
tar -xzf "$BACKUP_FILE"

# Restart the system
npm start
```

### Method 4: Database-Only Rollback
```bash
# For database issues only

# Stop the system
# Ctrl+C or kill the process

# Backup current database
cp data/gaa.db data/gaa.db.corrupt.$(date +%s)

# Option A: Use a previous database backup
cp data/backups/gaa.db.backup data/gaa.db

# Option B: Reset database (loses all history)
rm data/gaa.db data/gaa.db-*
# System will create fresh database on restart

# Restart
npm start
```

## 🛡️ Recovery Procedures

### After Rollback:

1. **Verify System Health**
```bash
# Check system status
curl http://localhost:3456/api/status | jq .

# Check recent activities
curl http://localhost:3456/api/activities | jq '.[0:5]'

# Verify database
sqlite3 data/gaa.db ".tables"
```

2. **Document the Incident**
Create a report in `data/rollback_log.md`:
```markdown
## Rollback Incident - [Date]
- **Issue**: [Description]
- **Method Used**: [Git/Hard Reset/Backup/Database]
- **Commit/Backup**: [Hash or filename]
- **Resolution**: [What fixed it]
- **Prevention**: [How to avoid in future]
```

3. **Update Agent Knowledge**
Create a file for agents to learn from:
```bash
cat > data/knowledge/rollback_incident_$(date +%Y%m%d).md << EOF
# System Rollback Event
Date: $(date)
Reason: [Issue description]
Lesson: [What to avoid]
EOF
```

## 🔄 Automated Rollback Script

For emergency automated rollback:

```bash
#!/bin/bash
# Save as emergency_rollback.sh

echo "🚨 EMERGENCY ROLLBACK INITIATED"

# 1. Stop any running processes
pkill -f "node.*server.js" || true

# 2. Create emergency backup
tar -czf emergency_$(date +%s).tar.gz src/ site/ data/

# 3. Git rollback to last known good commit
git reset --hard HEAD~1

# 4. Clean temporary files
rm -f data/*.db-shm data/*.db-wal
rm -f /tmp/gaa-*.log

# 5. Restart system
echo "🔄 Restarting system..."
npm start
```

## 📊 Rollback Metrics

Track rollback events:
- Frequency: How often rollbacks occur
- Root Cause: Common failure patterns
- Recovery Time: Time to restore service
- Data Loss: What was lost (if anything)

## 🎯 Prevention Strategies

1. **Regular Commits**: Use `./backup_schedule.sh continuous`
2. **Health Monitoring**: Check dashboard regularly
3. **Resource Limits**: Set API call limits in `.env`
4. **Testing Branch**: Test major changes in separate branch
5. **Incremental Changes**: Small, frequent updates vs large changes

## 📞 Escalation Path

If rollback fails:
1. Check GitHub for last known good version
2. Clone fresh from GitHub: `git clone https://github.com/[username]/gaa-5-testing`
3. Restore data from backups
4. Contact team for assistance

## 🔍 Common Issues & Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Database Lock | "database is locked" | Delete `.db-shm` and `.db-wal` files |
| API Quota | "quota exhausted" | Wait until midnight PST or reduce `MAX_APPROVED_STEPS_PER_LOOP` |
| Memory Leak | High memory usage | Restart system, check for infinite loops |
| YAML Parse Errors | Continuous failures | Rollback prompts.js to previous version |
| Git Conflicts | Can't push | Use `git pull --rebase` then resolve conflicts |

## 📝 Notes

- Always prefer `git revert` over `git reset` for public repos
- Keep at least 3 recent backups
- Test rollback procedures regularly
- Document every rollback incident
- Share lessons learned with the team

---
*Remember: Rollback is a safety net, not a solution. Focus on preventing issues through careful testing and gradual changes.*