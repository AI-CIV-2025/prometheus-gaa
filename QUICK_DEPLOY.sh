#!/bin/bash
# Quick deployment script for Project Prometheus
# Sets up GAA-5 with auto-wake in under 5 minutes

set -e
echo "🔥 Project Prometheus - Quick Deploy"
echo "===================================="

# Check prerequisites
command -v node >/dev/null 2>&1 || { echo "❌ Node.js not found. Please install Node.js 18+"; exit 1; }
command -v tmux >/dev/null 2>&1 || { echo "❌ tmux not found. Please install tmux"; exit 1; }
command -v claude >/dev/null 2>&1 || { echo "❌ Claude CLI not found. Run: npm install -g @anthropic-ai/claude"; exit 1; }

echo "✅ Prerequisites checked"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create required directories
echo "📁 Creating directories..."
mkdir -p data/{reports,architecture,code_skeletons,docs,knowledge,tools}
mkdir -p "$HOME/projects/GAA/ClaudeTodo/"{active,completed,agent-requests}

# Start agents
echo "🚀 Starting GAA agents..."
./start.sh

sleep 3

# Verify agents are running
if curl -s http://localhost:3456/api/status | grep -q "true"; then
    echo "✅ Agents running successfully"
else
    echo "❌ Agents failed to start. Check logs."
    exit 1
fi

echo ""
echo "===================================="
echo "✅ SETUP COMPLETE!"
echo ""
echo "Next steps:"
echo "1. Start tmux: tmux new -s claude"
echo "2. Inside tmux, run: claude"
echo "3. Detach tmux: Press Ctrl+B, then D"
echo "4. Run auto-wake setup: ./quick_wake_setup.sh"
echo ""
echo "Dashboard: http://localhost:3456/dashboard.html"
echo "API Status: http://localhost:3456/api/status"
echo ""
echo "🔥 Project Prometheus is ready!"