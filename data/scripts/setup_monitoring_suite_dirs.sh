#!/bin/bash
#
# setup_monitoring_suite_dirs.sh
#
# This script creates the necessary directory structure for the
# Self-Improving AI Agent Monitoring & Analysis Suite project.
# Running this ensures a clean and organized environment for all
# components and artifacts.

echo "Initializing directory structure for the Monitoring & Analysis Suite..."

# Base project directory
mkdir -p ./data/projects/monitoring_suite
echo "Created: ./data/projects/monitoring_suite"

# Directory to store collected artifacts from each run
mkdir -p ./data/projects/monitoring_suite/collected_artifacts
echo "Created: ./data/projects/monitoring_suite/collected_artifacts"

# Directory for the core tool scripts
mkdir -p ./data/projects/monitoring_suite/tools
echo "Created: ./data/projects/monitoring_suite/tools"

# Directory for logs and generated data
mkdir -p ./data/projects/monitoring_suite/output_data
echo "Created: ./data/projects/monitoring_suite/output_data"

# Create a placeholder for the insights log
touch ./data/projects/monitoring_suite/insights.log
echo "Created: ./data/projects/monitoring_suite/insights.log"

echo ""
echo "Directory structure setup complete."
ls -R ./data/projects/monitoring_suite

