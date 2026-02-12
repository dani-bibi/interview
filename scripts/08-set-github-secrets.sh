#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[Step 8/10] Setting GitHub Secrets${NC}"

# Get values from Terraform outputs
ECR_REPO_NAME=$(terraform -chdir=terraform output -raw ecr_repository_name)
ECS_CLUSTER=$(terraform -chdir=terraform output -raw ecs_cluster_name)
ECS_SERVICE=$(terraform -chdir=terraform output -raw ecs_service_name)
CLOUDFRONT_ID=$(terraform -chdir=terraform output -raw cloudfront_distribution_id)
AWS_REGION=$(terraform -chdir=terraform output -raw aws_region)

# Get AWS credentials from credentials file or environment
if [ -f ~/.aws/credentials ]; then
    AWS_ACCESS_KEY=$(grep -A2 "\[default\]" ~/.aws/credentials | grep aws_access_key_id | awk '{print $3}')
    AWS_SECRET_KEY=$(grep -A2 "\[default\]" ~/.aws/credentials | grep aws_secret_access_key | awk '{print $3}')
else
    AWS_ACCESS_KEY=${AWS_ACCESS_KEY_ID}
    AWS_SECRET_KEY=${AWS_SECRET_ACCESS_KEY}
fi

echo "Setting GitHub repository secrets..."

# Set secrets using gh CLI
gh secret set AWS_ACCESS_KEY_ID --body "$AWS_ACCESS_KEY"
gh secret set AWS_SECRET_ACCESS_KEY --body "$AWS_SECRET_KEY"
gh secret set ECR_REPOSITORY --body "$ECR_REPO_NAME"
gh secret set ECS_CLUSTER --body "$ECS_CLUSTER"
gh secret set ECS_SERVICE --body "$ECS_SERVICE"
gh secret set ECS_TASK_DEFINITION --body "interview-app-task"
gh secret set CONTAINER_NAME --body "interview-app-container"
gh secret set CLOUDFRONT_DISTRIBUTION_ID --body "$CLOUDFRONT_ID"

echo -e "${GREEN}✓${NC} AWS_ACCESS_KEY_ID set"
echo -e "${GREEN}✓${NC} AWS_SECRET_ACCESS_KEY set"
echo -e "${GREEN}✓${NC} ECR_REPOSITORY set: $ECR_REPO_NAME"
echo -e "${GREEN}✓${NC} ECS_CLUSTER set: $ECS_CLUSTER"
echo -e "${GREEN}✓${NC} ECS_SERVICE set: $ECS_SERVICE"
echo -e "${GREEN}✓${NC} ECS_TASK_DEFINITION set: interview-app-task"
echo -e "${GREEN}✓${NC} CONTAINER_NAME set: interview-app-container"
echo -e "${GREEN}✓${NC} CLOUDFRONT_DISTRIBUTION_ID set: $CLOUDFRONT_ID"

echo -e "${GREEN}✓ GitHub secrets configured${NC}\n"
