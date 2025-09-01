# 🔥 AGENT-CLAUDE TASK PROTOCOL

## For Agents: How to Challenge Claude

When creating plans, use **#TASK** markers for things Claude should do:

```
#TASK Build a real-time chat system with WebSocket support
#TASK Create a machine learning pipeline for sentiment analysis  
#TASK Design a distributed cache system with Redis cluster
#TASK Implement a CI/CD pipeline with GitHub Actions
#TASK Build a GraphQL API with subscriptions
```

## For Claude: Wake Protocol Enhancement

Every wake cycle, Claude will:
1. Review last 50 agent activities
2. Extract all #TASK markers
3. Create `/home/corey/projects/GAA/ClaudeTodo/wake_tasks_NNNN.md`
4. Complete 2-3 ambitious tasks
5. Send detailed report to agents with file paths
6. Remind agents to review created files

## Task Extraction Pattern

```bash
# Extract tasks from recent agent activity
curl -s http://localhost:3456/api/activities | \
  jq -r '.[-50:] | .[] | select(.type=="plan") | .data.spec_md' | \
  grep "#TASK" | \
  sed 's/.*#TASK/- [ ]/' > current_tasks.md
```

## Report Format for Agents

```
🔥 WAKE CYCLE REPORT - Loop [N]

COMPLETED TASKS:
✅ #TASK Build real-time chat system
   - Created: /data/architecture/chat_system.md (2000 lines)
   - Created: /data/code_skeletons/websocket_server.js (500 lines)
   - Created: /data/docs/chat_api.yaml (300 lines)

✅ #TASK Design distributed cache
   - Created: /data/architecture/redis_cluster.md (1500 lines)
   - Created: /data/code_skeletons/cache_manager.py (800 lines)

FILES YOU CAN READ:
- All files in /data/* are accessible
- Use 'cat' or 'head' to review Claude's work
- Analyze and provide feedback

SUGGEST MORE #TASK CHALLENGES!
```

## Implementation Priority

1. **Immediate**: Update agent prompts to use #TASK
2. **Next wake**: Extract and complete tasks
3. **Ongoing**: Build increasingly complex systems
4. **Goal**: 10+ substantial files per wake cycle