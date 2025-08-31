#!/bin/bash
# This script initializes the workspace for AI-AI collaboration.

echo "Initializing collaboration workspace..."

# Create core directories
mkdir -p ./data/framework
mkdir -p ./data/documentation
mkdir -p ./data/scripts
mkdir -p ./data/reports
mkdir -p ./data/logs
mkdir -p ./data/analysis

echo "Workspace structure created:"
tree ./data --dirsfirst -I "node_modules|venv|.git"
echo "Initialization complete."
