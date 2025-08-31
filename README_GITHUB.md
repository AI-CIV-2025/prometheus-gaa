# 🔥 Project Prometheus - Autonomous AI Collaboration System

## What is this?

An autonomous AI agent system that collaborates with Claude Code in real-time. The agents challenge Claude with ambitious projects, and Claude delivers MAGICAL solutions. The system runs indefinitely with an auto-wake mechanism that keeps Claude active every 5 minutes.

## Key Features

- **Autonomous Agents**: Self-improving AI system running continuous loops
- **Auto-Wake System**: Keeps Claude active indefinitely via tmux injection
- **Real-time Dashboard**: Monitor agent activity at http://localhost:3456/dashboard.html
- **TODO Management**: Agents file requests, Claude completes them
- **Verified Working**: Auto-wake tested and confirmed operational

## Quick Start (5 minutes)

```bash
# Clone and enter directory
git clone https://github.com/YOUR_USERNAME/prometheus-gaa.git
cd prometheus-gaa

# Run quick deploy
chmod +x QUICK_DEPLOY.sh
./QUICK_DEPLOY.sh

# Start Claude in tmux
tmux new -s claude
claude
# Press Ctrl+B, then D to detach

# Enable auto-wake
./quick_wake_setup.sh
```

## What You Get

1. **GAA Agents** running at Loop 24+ (as of Aug 31, 2025)
2. **Auto-wake** every 5 minutes - Claude stays active
3. **IoT Dashboard** with 2M events/sec architecture
4. **Complete API** specifications (OpenAPI 3.0)
5. **Extensive documentation** and setup guides

## Current Achievements

- ✅ 116 files, 10,736+ lines of code
- ✅ Auto-wake system verified working
- ✅ Agents successfully challenging Claude
- ✅ IoT Dashboard with sensor simulator
- ✅ Kafka ingestion pipeline
- ✅ TimescaleDB schema with aggregates

## File Structure

```
prometheus-gaa/
├── SETUP_INSTRUCTIONS.md   # Complete setup guide
├── QUICK_DEPLOY.sh         # 5-minute deployment
├── claude_auto_wake.sh     # Wake mechanism
├── src/                    # Agent source code
├── data/                   # Agent outputs
├── site/dashboard.html     # Real-time UI
└── ClaudeTodo/            # Task management
```

## Requirements

- Node.js 18+
- tmux
- Claude CLI (`npm install -g @anthropic-ai/claude`)
- Linux/macOS/WSL

## The Magic

The agents are designed to:
1. Challenge Claude with complex, ambitious requests
2. Analyze Claude's responses
3. Create substantial outputs (reports, code, architectures)
4. Learn and improve over time
5. Run forever without human intervention

## Support

See `SETUP_INSTRUCTIONS.md` for detailed setup and troubleshooting.

## Status

🟢 **OPERATIONAL** - System running, auto-wake active, agents at Loop 24+

---

*Project Prometheus - Bringing intelligence fire to autonomous agents*

Created: August 31, 2025 | Auto-wake verified: 8:30 AM EDT