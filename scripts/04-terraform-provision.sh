#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[Step 4/10] Provisioning AWS Infrastructure with Terraform${NC}"

cd terraform

# Initialize Terraform
if [ ! -d .terraform ]; then
    echo "Initializing Terraform..."
    terraform init
    echo -e "${GREEN}✓${NC} Terraform initialized"
else
    echo -e "${GREEN}✓${NC} Terraform already initialized"
fi

# Apply Terraform configuration
echo "Applying Terraform configuration (this may take 10-15 minutes)..."
terraform apply -auto-approve

echo -e "${GREEN}✓${NC} AWS infrastructure provisioned"

cd ..
echo -e "${GREEN}✓ Terraform provisioning complete${NC}\n"
