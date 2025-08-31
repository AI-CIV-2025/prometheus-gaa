#!/bin/bash

echo "🚀 Starting GAA-5.0 Autonomous Agent System"
echo "=========================================="

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Check if database exists
if [ ! -f "./data/gaa.db" ]; then
    echo "🗄️ Creating initial database..."
    mkdir -p ./data
    node -e "import('./src/database.js').then(({setup}) => setup())"
fi

# Start the server
echo "✅ Starting server on port 3456..."
npm start