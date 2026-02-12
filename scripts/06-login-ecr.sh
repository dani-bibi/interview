#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[Step 6/10] Logging into Amazon ECR${NC}"

# Get AWS region and ECR registry
AWS_REGION=$(terraform -chdir=terraform output -raw aws_region)
ECR_URL=$(terraform -chdir=terraform output -raw ecr_repository_url)
ECR_REGISTRY=$(echo $ECR_URL | cut -d'/' -f1)

echo "ECR Registry: $ECR_REGISTRY"
echo "Region: $AWS_REGION"

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin $ECR_REGISTRY

echo -e "${GREEN}✓${NC} Logged into Amazon ECR"
echo -e "${GREEN}✓ ECR login complete${NC}\n"
