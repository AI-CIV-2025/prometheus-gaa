# GAA-5-TESTING - Testing Environment for GAA-5.0

This is the testing/development version of GAA-5.0 for experimenting with optimizations and improvements.

## Quick Start

```bash
# Install dependencies
npm install

# Start the server
npm start
```

Access the dashboard at: http://localhost:3456/dashboard.html

## Environment Setup

Ensure your `.env` file contains:
```
GOOGLE_API_KEY=your-key-here
PORT=3456
DB_PATH=./data/gaa.db
MODEL_PRO=gemini-2.5-pro
MODEL_FLASH=gemini-2.5-flash
AUTO_APPROVE_RISK_THRESHOLD=0.4
MAX_APPROVED_STEPS_PER_LOOP=15
API_DELAY_MS=15000
SYSTEM_AGENT_INTERVAL=10
EXECUTION_PATH=./data
```

## Key Improvements from GAA-4

1. **Optimized API Usage**: Reduced from 30 to ~3 API calls per loop
2. **Better YAML Parsing**: Fixes for common parsing issues
3. **Clear Context**: Execution policy included in agent context
4. **Meaningful Reflections**: Forces analysis of specific failures
5. **Comprehensive Logging**: Full conversation and activity tracking

## Directory Structure

```
gaa-5-testing/
├── src/
│   ├── agents/         # Agent implementations
│   ├── database.js     # Database setup
│   ├── prompts.js      # Agent prompts
│   ├── server.js       # Main server
│   └── ...
├── site/              # Web dashboard
├── data/              # Runtime data (created on first run)
└── exec_policy.json   # Command whitelist
```

## Mission

The agent's core mission is to build substantial tools and analysis systems, creating at least 3 meaningful artifacts per loop.

## Monitoring

- Dashboard: http://localhost:3456/dashboard.html
- Agent Stream: http://localhost:3456/agent-stream.html
- API Status: http://localhost:3456/api/status
- Activities: http://localhost:3456/api/activities
- Reflections: http://localhost:3456/api/reflections