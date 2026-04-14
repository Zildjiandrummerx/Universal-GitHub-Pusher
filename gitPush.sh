#!/bin/bash
# ============================================================
# UNIVERSAL GITHUB PROJECT PUSHER (TEMPLATE)
# ============================================================
# This script automates the initialization, staging, committing, 
# and authenticated pushing of a local directory to a GitHub repository.
# It resolves the "Unrelated Histories" error automatically.
#
# PREREQUISITES:
# 1. Create an empty repository on GitHub.com.
# 2. Generate a Personal Access Token (Classic) with 'repo' scope.
#    (GitHub Settings -> Developer Settings -> Personal access tokens)
# 3. 🛑 SECURITY: Add the name of this script to your .gitignore file 
#    so you do not accidentally publish your token!
#
# USAGE:
# 1. Place this script in your project's root directory.
# 2. Make it executable: chmod +x github_push.sh
# 3. Run it: ./github_push.sh
# ============================================================

set -e # Exit immediately if a command fails

# ============================================================
# 1. USER CONFIGURATION (⚠️ YOU MUST CHANGE THESE VARIABLES)
# ============================================================

# Your exact GitHub username
GITHUB_USER="your_github_username"

# The email address tied to your GitHub account
GITHUB_EMAIL="your_email@example.com"

# Your GitHub Personal Access Token (starts with ghp_...)
GITHUB_TOKEN="ghp_REPLACE_WITH_YOUR_TOKEN"

# The exact name of the destination repository on GitHub
# (e.g., if the URL is github.com/user/My-Project, type "My-Project")
GITHUB_REPO_NAME="Your-Target-Repo-Name"


# ============================================================
# 2. AUTOMATIC PROJECT DETECTION & SETUP
# ============================================================
PROJECT_DIR=$(pwd)
PROJECT_NAME=$(basename "$PROJECT_DIR")

echo "============================================================"
echo "🚀 INITIATING GITHUB PUSH SEQUENCE"
echo "Project Directory: $PROJECT_DIR"
echo "Target Repository: $GITHUB_REPO_NAME"
echo "============================================================"

# Configure Git locally to ensure commits are tied to your professional identity
git config --global user.name "$GITHUB_USER"
git config --global user.email "$GITHUB_EMAIL"

# Silences the annoying "master vs main" warning from Git
git config --global init.defaultBranch main 

# Initialize git if this is a brand new project
if [ ! -d ".git" ]; then
  echo "[+] Initializing new local Git repository..."
  git init
fi

# ============================================================
# 3. README VALIDATION
# ============================================================
# The script specifically looks for README.md in the current directory.
# If it exists, it confirms inclusion. If missing, it alerts the user.
if [ -f "README.md" ]; then
    echo "[+] README.md detected. Including documentation in payload."
else
    echo "[-] WARNING: README.md not found in this directory."
    echo "    Creating a temporary placeholder README.md..."
    echo "# $GITHUB_REPO_NAME" > README.md
    echo "Documentation pending." >> README.md
fi

# ============================================================
# 4. STAGE & COMMIT
# ============================================================
echo "[+] Staging project files..."
# This command explicitly adds EVERYTHING in the directory, including README.md and code files.
git add .

echo "[+] Creating commit..."
# Captures the current timestamp for a precise commit message
COMMIT_TIME=$(date "+%Y-%m-%d %H:%M:%S")

# We use || true so the script doesn't crash if ran twice without making changes
git commit -m "Automated Project Push: $COMMIT_TIME - Code and infrastructure updates" || true

# Set the default branch to 'main'
git branch -M main

# ============================================================
# 5. SECURE AUTHENTICATED PUSH & AUTO-RESOLVE
# ============================================================
# Dynamically constructs the secure HTTPS URL using the token, 
# preventing authentication prompts from interrupting the script.
AUTH_REPO_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO_NAME}.git"

echo "[+] Configuring remote origin..."
# Suppress error if 'origin' doesn't exist yet, then add the new secure URL
git remote remove origin 2>/dev/null || true
git remote add origin "$AUTH_REPO_URL"

echo "[+] Pushing payload to GitHub..."

# THE ARCHITECT'S FALLBACK:
# 1. It tries to push normally (sending errors to /dev/null to keep the console clean).
# 2. If GitHub rejects it (usually because of mismatched initial commits), the 'if' statement catches it.
# 3. It automatically executes a --force push, asserting your local machine as the absolute source of truth.
if ! git push -u origin main > /dev/null 2>&1; then
    echo "[-] Normal push rejected by GitHub (Mismatched Histories detected)."
    echo "[!] Initiating Force Push to assert local directory as the Source of Truth..."
    git push -u origin main --force
fi

echo "============================================================"
echo "✅ PUSH COMPLETED SUCCESSFULLY."
echo "Live Repository: https://github.com/${GITHUB_USER}/${GITHUB_REPO_NAME}"
echo "============================================================"