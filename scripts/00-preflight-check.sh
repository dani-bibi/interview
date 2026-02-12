#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              PRE-FLIGHT CHECK FOR INTERVIEW                    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

ISSUES=0

# Check 1: Docker
echo -n "Checking Docker... "
if docker ps >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Working${NC}"
else
    echo -e "${RED}✗ Need to fix${NC}"
    echo "  Fix: Run 'newgrp docker' or 'sudo service docker start'"
    ISSUES=$((ISSUES + 1))
fi

# Check 2: AWS
echo -n "Checking AWS credentials... "
if aws sts get-caller-identity >/dev/null 2>&1; then
    ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    echo -e "${GREEN}✓ Authenticated (Account: $ACCOUNT)${NC}"
else
    echo -e "${RED}✗ Not configured${NC}"
    ISSUES=$((ISSUES + 1))
fi

# Check 3: GitHub
echo -n "Checking GitHub CLI... "
if gh auth status >/dev/null 2>&1; then
    GH_USER=$(gh api user -q .login)
    echo -e "${GREEN}✓ Authenticated as $GH_USER${NC}"
else
    echo -e "${RED}✗ Not authenticated${NC}"
    ISSUES=$((ISSUES + 1))
fi

# Check 4: Terraform
echo -n "Checking Terraform init... "
if [ -d terraform/.terraform ]; then
    echo -e "${GREEN}✓ Initialized${NC}"
else
    echo -e "${YELLOW}⚠ Not initialized (will be done automatically)${NC}"
fi

# Check 5: Project files
echo -n "Checking project structure... "
FILE_COUNT=$(find . -type f \( -name "*.py" -o -name "*.tf" -o -name "*.sh" -o -name "*.yml" \) ! -path "./.git/*" ! -path "./.terraform/*" | wc -l)
if [ $FILE_COUNT -ge 25 ]; then
    echo -e "${GREEN}✓ $FILE_COUNT files present${NC}"
else
    echo -e "${RED}✗ Missing files (found $FILE_COUNT, expected 25+)${NC}"
    ISSUES=$((ISSUES + 1))
fi

echo ""

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ ALL CHECKS PASSED - READY FOR INTERVIEW DEPLOYMENT!        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Next step: ${CYAN}./scripts/setup.sh${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}Found $ISSUES issue(s) - please fix before deploying${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
    exit 1
fi
