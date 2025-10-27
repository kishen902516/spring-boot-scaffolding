#!/bin/bash

# Pre-Feature GitHub Check Hook
# Lightweight validation before starting feature development
# Called by feature-developer agent before creating issues/branches

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}❌ Not a git repository${NC}"
    echo "Initialize with: git init"
    exit 1
fi

# Check if remote is GitHub
REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")
if [[ ! "$REMOTE_URL" == *"github.com"* ]]; then
    echo -e "${RED}❌ Remote origin is not GitHub${NC}"
    echo "Current remote: $REMOTE_URL"
    echo "Set GitHub remote: git remote add origin https://github.com/user/repo.git"
    exit 1
fi

# Check for GITHUB_TOKEN
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ GITHUB_TOKEN environment variable not set${NC}"
    echo "Set with: export GITHUB_TOKEN='your-token'"
    exit 1
fi

# All checks passed
echo -e "${GREEN}✅ GitHub integration prerequisites met${NC}"
exit 0
