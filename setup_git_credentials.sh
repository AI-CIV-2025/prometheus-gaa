#!/bin/bash

# Git Credentials Setup Helper
# This script helps you safely configure Git credentials

echo "🔐 Git Credentials Configuration"
echo "================================"
echo ""
echo "Please provide your GitHub credentials for the public repository."
echo "These will be stored in environment variables for the current session."
echo ""

# Prompt for credentials
read -p "GitHub Username: " GIT_USERNAME
read -s -p "GitHub Personal Access Token (ghp_...): " GIT_TOKEN
echo ""

# Export for current session
export GIT_USERNAME="$GIT_USERNAME"
export GIT_TOKEN="$GIT_TOKEN"

echo ""
echo "✅ Credentials set for current session"
echo ""
echo "Now run: ./git_setup.sh"
echo ""
echo "To make permanent (BE CAREFUL - PUBLIC REPO):"
echo "Add to .env file:"
echo "  GIT_USERNAME=$GIT_USERNAME"
echo "  GIT_TOKEN=ghp_..."  # Don't echo the actual token
echo ""
echo "⚠️ REMINDER: Never commit .env file to the repository!"