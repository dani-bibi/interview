#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[Step 7/10] Pushing Docker Image to ECR${NC}"

# Get ECR repository URL
ECR_URL=$(terraform -chdir=terraform output -raw ecr_repository_url)

echo "Pushing image to: $ECR_URL:latest"

# Push to ECR
docker push $ECR_URL:latest

echo -e "${GREEN}✓${NC} Docker image pushed to ECR"
echo -e "${GREEN}✓ ECR push complete${NC}\n"
