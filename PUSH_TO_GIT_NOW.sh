#!/bin/bash
# PUSH TO GITHUB - Project Prometheus
# Run this script after creating "prometheus" repo on GitHub

echo "🔥 Pushing Project Prometheus to GitHub"
echo "======================================="

# Check if remote exists
if git remote | grep -q origin; then
    echo "❌ Remote 'origin' already exists. Removing..."
    git remote remove origin
fi

# Get GitHub username
read -p "Enter your GitHub username: " GITHUB_USER

# Add remote
echo "Adding remote for prometheus repo..."
git remote add origin "https://github.com/${GITHUB_USER}/prometheus.git"

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin master

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Project Prometheus is now on GitHub!"
    echo ""
    echo "Repository URL: https://github.com/${GITHUB_USER}/prometheus"
    echo ""
    echo "Anyone can now clone and run:"
    echo "  git clone https://github.com/${GITHUB_USER}/prometheus.git"
    echo "  cd prometheus"
    echo "  ./QUICK_DEPLOY.sh"
    echo ""
    echo "🔥 The fire has been shared!"
else
    echo ""
    echo "❌ Push failed. Please ensure:"
    echo "1. You've created 'prometheus' repo on GitHub.com"
    echo "2. You have push access to the repo"
    echo "3. Your credentials are correct"
    echo ""
    echo "Manual push command:"
    echo "  git push -u origin master"
fi