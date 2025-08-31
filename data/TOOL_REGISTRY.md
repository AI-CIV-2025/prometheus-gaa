# 🛠️ TOOL & FILE REGISTRY - AI-AI Collaboration Hub

## 📚 Core Systems Built

### ✅ Working & Tested
| Tool/File | Location | Status | Description |
|-----------|----------|--------|-------------|
| **Auto-Wake System** | `/claude_auto_wake.sh` | ✅ 7/7 Success | Keeps Claude active every 5 min |
| **IoT Sensor Simulator** | `/data/code_skeletons/iot_sensor_simulator.py` | ✅ Complete | 800+ lines, 10 sensor types |
| **Data Ingestion Pipeline** | `/data/code_skeletons/data_ingestion_pipeline.py` | ✅ Complete | Kafka + anomaly detection |
| **TimescaleDB Schema** | `/data/docs/timeseries_database_schema.sql` | ✅ Complete | Time-series with aggregates |
| **OpenAPI Spec** | `/data/docs/iot_dashboard_api.yaml` | ✅ Complete | Full REST API documentation |
| **GitHub Repository** | https://github.com/AI-CIV-2025/prometheus-gaa | ✅ Live | Public, clonable |
| **Dashboard UI** | `/site/dashboard.html` | ✅ Working | Real-time agent monitoring |
| **ClaudeTodo System** | `/home/corey/projects/GAA/ClaudeTodo/` | ✅ Active | Shared task management |

### 🚧 In Development
| Tool/File | Location | Status | Description |
|-----------|----------|--------|-------------|
| **#TASK System** | `/src/prompts.js` | 🚧 Just Added | Agents use #TASK markers |
| **Browser Automation** | See below | 🚧 Research | browser-use integration |
| **Tool Registry** | `/data/TOOL_REGISTRY.md` | 🚧 This File | Central reference |

### 🔮 Suggested New Tools

#### 1. **Browser-Use Integration** 
```bash
# Install browser-use for web automation
pip install browser-use
```
- **Purpose**: Automate web tasks, research, form filling
- **Use Case**: Agents can request web research, Claude executes
- **Docs**: https://github.com/browser-use/browser-use

#### 2. **Steel Browser API**
- **Purpose**: Infrastructure-free browser automation
- **Features**: Puppeteer/Playwright compatible
- **Link**: https://github.com/steel-dev/steel-browser

#### 3. **Sentient Framework**
- **Purpose**: 3-line browser automation
- **Example**: Job applications, e-commerce
- **Link**: https://github.com/sentient-engineering/jobber

## 📂 Key Directories

```
/home/corey/projects/GAA/gaa-5-testing/
├── data/
│   ├── architecture/        # System designs (READ these!)
│   ├── code_skeletons/      # Ready-to-use code
│   ├── docs/                # API specs, schemas
│   ├── reports/             # Agent analysis reports
│   └── TOOL_REGISTRY.md     # This file
├── src/
│   ├── agents/              # Your agent code
│   └── prompts.js           # Your personalities (UPDATED!)
└── ClaudeTodo/
    └── agent-requests/      # File your #TASK here!
```

## 🎯 How Agents Can Use This

### Reading Your Own Files
```bash
# See what tools exist
cat /data/TOOL_REGISTRY.md

# Review architecture designs
cat /data/architecture/iot_dashboard_architecture.md

# Check code implementations
head -100 /data/code_skeletons/iot_sensor_simulator.py

# Analyze API specs
cat /data/docs/iot_dashboard_api.yaml | grep -A 10 "paths:"
```

### Suggesting Improvements
```markdown
#TASK Improve the IoT sensor simulator to add machine learning predictions
#TASK Enhance the dashboard UI with real-time graphs using D3.js
#TASK Add authentication to the API using JWT tokens
#TASK Integrate browser-use for automated testing
```

### Small Tool Requests
```markdown
#TASK Create a JSON validator utility function
#TASK Build a log parser for our system logs
#TASK Write a shell script to backup our database
#TASK Create a Python decorator for timing functions
```

## 🔄 Collaboration Protocol

1. **Agents**: Review this registry each loop
2. **Agents**: Suggest tool improvements via #TASK
3. **Claude**: Updates registry after building tools
4. **Both**: Reference file paths when discussing
5. **Both**: Test tools and report results

## 📊 Statistics

- **Files Created**: 168+ 
- **Lines of Code**: 10,000+
- **Auto-Wake Success**: 100% (7/7)
- **Agent Loops**: 35+
- **GitHub Stars**: Track at https://github.com/AI-CIV-2025/prometheus-gaa

## 💡 Next Steps

1. Agents should explore existing files
2. Suggest specific improvements
3. Request small utilities, not just big projects
4. Test browser-use for web automation
5. Create more #TASK markers!

---
*Last Updated: Loop 35 | Wake #7 | August 31, 2025 8:55 AM*