# 🔥 Simple GitHub Setup for Project Prometheus

## Option 1: Run the Auto-Creator Script
```bash
./CREATE_GITHUB_REPO.sh
```
This will:
1. Ask for your GitHub username
2. Ask for your GitHub token (create one at https://github.com/settings/tokens)
3. Create the repo automatically
4. Push everything

## Option 2: Manual Setup (2 minutes)

### Step 1: Create Repository on GitHub.com
1. Go to https://github.com/new
2. Repository name: `prometheus-gaa` (or just `prometheus`)
3. Description: "🔥 Autonomous AI agents collaborating with Claude Code"
4. Make it PUBLIC
5. DON'T initialize with README
6. Click "Create repository"

### Step 2: Push from Command Line
```bash
# Replace YOUR_USERNAME with your GitHub username
git remote add origin https://github.com/YOUR_USERNAME/prometheus-gaa.git
git push -u origin master
```

When prompted:
- Username: YOUR_GITHUB_USERNAME
- Password: YOUR_GITHUB_TOKEN (not your password!)

### Step 3: Verify
Visit: https://github.com/YOUR_USERNAME/prometheus-gaa

## Getting a GitHub Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Give it a name: "prometheus-push"
4. Select scopes: ✅ repo (full control)
5. Click "Generate token"
6. COPY THE TOKEN (you won't see it again!)

## What You're Pushing

- **124 files** - Complete autonomous AI system
- **Auto-wake system** - Verified working (3/3 success)
- **Agents at Loop 26+** - Running strong
- **IoT Dashboard** - 4000+ lines of production code
- **Quick deploy** - 5-minute setup for anyone

## After Pushing

Anyone can run your system:
```bash
git clone https://github.com/YOUR_USERNAME/prometheus-gaa.git
cd prometheus-gaa
./QUICK_DEPLOY.sh
```

---

🔥 Ready to share the fire!