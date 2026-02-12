#!/bin/bash

# Cleanup script to destroy all AWS resources
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}AWS Infrastructure Cleanup${NC}"
echo ""
echo -e "${RED}WARNING: This will destroy all AWS resources created by Terraform!${NC}"
echo -e "This includes:"
echo "  - CloudFront distribution"
echo "  - Application Load Balancer"
echo "  - ECS cluster and service"
echo "  - ECR repository (and all images)"
echo "  - VPC and networking components"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Destroying AWS infrastructure..."

cd terraform
terraform destroy -auto-approve
cd ..

echo -e "${GREEN}✓ AWS infrastructure destroyed${NC}"
echo ""

read -p "Do you want to delete the GitHub repository? (yes/no): " delete_repo

if [ "$delete_repo" == "yes" ]; then
    echo "Deleting GitHub repository..."
    gh repo delete --yes
    echo -e "${GREEN}✓ GitHub repository deleted${NC}"
fi

echo ""
echo -e "${GREEN}Cleanup complete!${NC}"
