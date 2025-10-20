#!/bin/bash

# Spring Boot CLI - Quick Update Script
# Updates the CLI to the latest version from GitHub

set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}[INFO]${NC} Updating Spring Boot CLI..."

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

# Stash any local changes
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}[WARNING]${NC} Local changes detected, stashing..."
    git stash
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${BLUE}[INFO]${NC} Current branch: $CURRENT_BRANCH"

# Pull latest changes
echo -e "${BLUE}[INFO]${NC} Pulling latest changes..."
git pull origin "$CURRENT_BRANCH" || {
    echo -e "${YELLOW}[WARNING]${NC} Failed to pull from $CURRENT_BRANCH, trying main/master..."
    git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || {
        echo -e "${RED}[ERROR]${NC} Failed to pull updates"
        exit 1
    }
}

# Set permissions
echo -e "${BLUE}[INFO]${NC} Setting executable permissions..."
chmod +x bin/springboot-cli.sh
chmod +x bin/commands/*.sh

echo -e "${GREEN}[SUCCESS]${NC} CLI updated successfully!"

# Show latest commit
echo ""
echo -e "${BLUE}[INFO]${NC} Latest commit:"
git log -1 --oneline

echo ""
echo -e "${BLUE}[INFO]${NC} Run 'springboot-cli help' to see available commands"
