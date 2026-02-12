#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[Step 2/10] Initializing Git Repository${NC}"

# Check if already a git repo
if [ -d .git ]; then
    echo -e "${GREEN}✓${NC} Git repository already initialized"
else
    git init
    echo -e "${GREEN}✓${NC} Git repository initialized"
fi

# Configure git user if not set
if ! git config user.name >/dev/null 2>&1; then
    git config user.name "Interview User"
    echo -e "${GREEN}✓${NC} Git user.name set"
fi

if ! git config user.email >/dev/null 2>&1; then
    git config user.email "interview@example.com"
    echo -e "${GREEN}✓${NC} Git user.email set"
fi

echo -e "${GREEN}✓ Git repository ready${NC}\n"
