#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[Step 1/10] Checking Prerequisites${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required tools
MISSING=0

echo "Checking required tools..."

if command_exists git; then
    echo -e "${GREEN}✓${NC} Git installed: $(git --version | head -n1)"
else
    echo -e "${RED}✗${NC} Git not found"
    MISSING=1
fi

if command_exists docker; then
    echo -e "${GREEN}✓${NC} Docker installed: $(docker --version)"
    # Check if docker daemon is running
    if docker ps >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker daemon is running"
    else
        echo -e "${RED}✗${NC} Docker daemon is not running. Start it with: sudo service docker start"
        MISSING=1
    fi
else
    echo -e "${RED}✗${NC} Docker not found"
    MISSING=1
fi

if command_exists terraform; then
    echo -e "${GREEN}✓${NC} Terraform installed: $(terraform --version | head -n1)"
else
    echo -e "${RED}✗${NC} Terraform not found"
    MISSING=1
fi

if command_exists aws; then
    AWS_VERSION=$(aws --version 2>&1 | head -n1 || echo "AWS CLI")
echo -e "${GREEN}✓${NC} AWS CLI installed: $AWS_VERSION"
else
    echo -e "${RED}✗${NC} AWS CLI not found"
    MISSING=1
fi

if command_exists gh; then
    echo -e "${GREEN}✓${NC} GitHub CLI installed: $(gh --version | head -n1)"
else
    echo -e "${RED}✗${NC} GitHub CLI not found"
    MISSING=1
fi

# Check AWS authentication
echo ""
echo "Checking authentication..."

if aws sts get-caller-identity >/dev/null 2>&1; then
    AWS_IDENTITY=$(aws sts get-caller-identity)
    AWS_USER=$(echo $AWS_IDENTITY | grep -o '"UserId":"[^"]*"' | cut -d'"' -f4)
    AWS_ACCOUNT=$(echo $AWS_IDENTITY | grep -o '"Account":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GREEN}✓${NC} AWS authenticated as: $AWS_USER (Account: $AWS_ACCOUNT)"
else
    echo -e "${RED}✗${NC} AWS credentials not configured. Run: aws configure"
    MISSING=1
fi

if gh auth status >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} GitHub CLI authenticated"
else
    echo -e "${RED}✗${NC} GitHub CLI not authenticated. Run: gh auth login"
    MISSING=1
fi

# Exit if any prerequisite is missing
if [ $MISSING -eq 1 ]; then
    echo -e "\n${RED}ERROR: Some prerequisites are missing. Please install them and try again.${NC}"
    exit 1
fi

echo -e "\n${GREEN}✓ All prerequisites met!${NC}\n"
