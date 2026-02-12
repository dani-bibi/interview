#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[Step 5/10] Building Docker Image${NC}"

# Get ECR repository URL from Terraform output
ECR_URL=$(terraform -chdir=terraform output -raw ecr_repository_url)

echo "Building Docker image..."
echo "ECR Repository: $ECR_URL"

# Build with latest tag
docker build -t $ECR_URL:latest .

echo -e "${GREEN}✓${NC} Docker image built: $ECR_URL:latest"
echo -e "${GREEN}✓ Docker build complete${NC}\n"
