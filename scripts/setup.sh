#!/bin/bash

# Master setup script that orchestrates all deployment steps
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
START_TIME=$(date +%s)

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         AWS ECS Interview Application Deployment              ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to run a step
run_step() {
    local script=$1
    if [ -f "$SCRIPT_DIR/$script" ]; then
        bash "$SCRIPT_DIR/$script"
    else
        echo -e "${RED}ERROR: Script $script not found${NC}"
        exit 1
    fi
}

# Execute all steps in order
run_step "01-check-prerequisites.sh"
run_step "02-init-git.sh"
run_step "03-create-github-repo.sh"
run_step "04-terraform-provision.sh"
run_step "05-build-docker-image.sh"
run_step "06-login-ecr.sh"
run_step "07-push-to-ecr.sh"
run_step "08-set-github-secrets.sh"
run_step "09-git-push.sh"
run_step "10-display-outputs.sh"

# Calculate elapsed time
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                   DEPLOYMENT SUCCESSFUL!                       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Total time elapsed: ${MINUTES}m ${SECONDS}s${NC}"
echo ""
