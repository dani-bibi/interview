#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[Step 9/10] Pushing Code to GitHub${NC}"

# Add all files
git add .

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo -e "${GREEN}✓${NC} No changes to commit (already pushed)"
else
    # Commit changes
    git commit -m "Initial deployment setup" || true
    echo -e "${GREEN}✓${NC} Changes committed"
fi

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null || git branch -M main && git push -u origin main

echo -e "${GREEN}✓${NC} Code pushed to GitHub"
echo -e "${GREEN}✓ Git push complete${NC}\n"
