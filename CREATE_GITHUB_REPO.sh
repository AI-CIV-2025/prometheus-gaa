#!/bin/bash
# Create GitHub repository and push Project Prometheus

set -e

echo "🔥 Project Prometheus - GitHub Repository Creator"
echo "================================================="
echo ""

# Get GitHub credentials
read -p "Enter your GitHub username: " GITHUB_USER
read -s -p "Enter your GitHub personal access token (with 'repo' scope): " GITHUB_TOKEN
echo ""

# Repository configuration
REPO_NAME="prometheus-gaa"
REPO_DESCRIPTION="🔥 Autonomous AI agents collaborating with Claude Code - Auto-wake system verified working!"

echo ""
echo "Creating repository: ${REPO_NAME}"
echo "Description: ${REPO_DESCRIPTION}"
echo ""

# Create repository via GitHub API
echo "📝 Creating repository on GitHub..."
RESPONSE=$(curl -s -X POST \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d "{
    \"name\": \"${REPO_NAME}\",
    \"description\": \"${REPO_DESCRIPTION}\",
    \"homepage\": \"https://github.com/${GITHUB_USER}/${REPO_NAME}\",
    \"private\": false,
    \"has_issues\": true,
    \"has_projects\": true,
    \"has_wiki\": false,
    \"auto_init\": false
  }")

# Check if creation was successful
if echo "$RESPONSE" | grep -q "\"full_name\""; then
    echo "✅ Repository created successfully!"
    REPO_URL=$(echo "$RESPONSE" | grep -o '"clone_url":"[^"]*' | grep -o '[^"]*$')
    echo "Repository URL: ${REPO_URL}"
else
    echo "❌ Failed to create repository. Error:"
    echo "$RESPONSE" | jq .
    echo ""
    echo "Common issues:"
    echo "1. Repository name already exists"
    echo "2. Invalid token (needs 'repo' scope)"
    echo "3. Rate limit exceeded"
    exit 1
fi

# Configure git remote
echo ""
echo "📤 Configuring git and pushing..."

# Remove existing origin if present
git remote remove origin 2>/dev/null || true

# Add new remote
git remote add origin "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"

# Push to GitHub
echo "Pushing all commits to GitHub..."
git push -u origin master

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================="
    echo "✅ SUCCESS! Project Prometheus is live!"
    echo "========================================="
    echo ""
    echo "🔗 Repository: https://github.com/${GITHUB_USER}/${REPO_NAME}"
    echo ""
    echo "📋 Clone command for others:"
    echo "   git clone https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
    echo ""
    echo "🚀 Quick setup for new machines:"
    echo "   git clone https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
    echo "   cd ${REPO_NAME}"
    echo "   ./QUICK_DEPLOY.sh"
    echo ""
    echo "📊 Status:"
    echo "   - Auto-wake system: VERIFIED WORKING"
    echo "   - Agents: Loop 26+"
    echo "   - Files: 124"
    echo "   - Ready for deployment!"
    echo ""
    echo "🔥 The fire has been lit!"
else
    echo "❌ Push failed. Check your credentials and try again."
fi

# Clean sensitive data from remote URL
git remote set-url origin "https://github.com/${GITHUB_USER}/${REPO_NAME}.git"