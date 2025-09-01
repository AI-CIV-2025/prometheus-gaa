#!/bin/bash
# Create core project directories
mkdir -p ./data/docs
mkdir -p ./data/src
mkdir -p ./data/logs
mkdir -p ./data/configs
mkdir -p ./data/reports

# Create initial placeholder files
touch ./data/docs/README.md
touch ./data/src/main.py
touch ./data/logs/research.log
touch ./data/configs/settings.yaml
touch ./data/reports/initial_analysis.md

echo "Project structure initialized in ${EXECUTION_PATH:-./data}"
ls -R ./data
