#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${YELLOW}[Step 10/10] Deployment Complete!${NC}\n"

# Get all outputs from Terraform
CLOUDFRONT_URL=$(terraform -chdir=terraform output -raw cloudfront_url)
CLOUDFRONT_DOMAIN=$(terraform -chdir=terraform output -raw cloudfront_domain_name)
CLOUDFRONT_ID=$(terraform -chdir=terraform output -raw cloudfront_distribution_id)
ALB_DNS=$(terraform -chdir=terraform output -raw alb_dns_name)
ECR_URL=$(terraform -chdir=terraform output -raw ecr_repository_url)
ECS_CLUSTER=$(terraform -chdir=terraform output -raw ecs_cluster_name)
ECS_SERVICE=$(terraform -chdir=terraform output -raw ecs_service_name)

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    DEPLOYMENT SUMMARY                          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ CloudFront URL:${NC}"
echo -e "  ${BLUE}$CLOUDFRONT_URL${NC}"
echo ""
echo -e "${GREEN}✓ CloudFront Domain:${NC} $CLOUDFRONT_DOMAIN"
echo -e "${GREEN}✓ CloudFront Distribution ID:${NC} $CLOUDFRONT_ID"
echo -e "${GREEN}✓ ALB DNS Name:${NC} $ALB_DNS"
echo -e "${GREEN}✓ ECR Repository:${NC} $ECR_URL"
echo -e "${GREEN}✓ ECS Cluster:${NC} $ECS_CLUSTER"
echo -e "${GREEN}✓ ECS Service:${NC} $ECS_SERVICE"
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    VERIFICATION STEPS                          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "1. Access the CloudFront URL in your browser:"
echo -e "   ${BLUE}$CLOUDFRONT_URL${NC}"
echo ""
echo "2. The page should display your public IP address"
echo ""
echo "3. Check ECS service status:"
echo "   aws ecs describe-services --cluster $ECS_CLUSTER --services $ECS_SERVICE --region us-east-1"
echo ""
echo "4. View GitHub Actions workflow:"
echo "   gh repo view --web"
echo ""
echo -e "${GREEN}✓ Setup Complete!${NC}\n"
