#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[Step 3/10] Creating GitHub Repository${NC}"

# Check if remote already exists
if git remote get-url origin >/dev/null 2>&1; then
    REMOTE_URL=$(git remote get-url origin)
    echo -e "${GREEN}✓${NC} GitHub remote already configured: $REMOTE_URL"
else
    # Create GitHub repository
    echo "Creating GitHub repository 'interview'..."
    
    if gh repo create interview --public --source=. --remote=origin --push=false; then
        echo -e "${GREEN}✓${NC} GitHub repository created"
    else
        # Repository might already exist, try to add remote
        GH_USER=$(gh api user -q .login)
        git remote add origin "https://github.com/$GH_USER/interview.git" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} GitHub remote configured"
    fi
fi

echo -e "${GREEN}✓ GitHub repository ready${NC}\n"
