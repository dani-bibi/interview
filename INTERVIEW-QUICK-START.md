# 🚀 Interview Quick Start Guide

## Before the Interview

```bash
# 1. Open terminal and activate Docker permissions
newgrp docker

# 2. Validate everything is ready
./scripts/00-preflight-check.sh

# Expected output: "ALL CHECKS PASSED - READY FOR INTERVIEW DEPLOYMENT!"
```

## During the Interview - Single Command

```bash
./scripts/setup.sh
```

**What this does:** Runs all 10 deployment steps automatically (15-20 minutes)

## If You Need to Show Individual Steps

```bash
./scripts/01-check-prerequisites.sh  # Verify tools
./scripts/02-init-git.sh            # Git init
./scripts/03-create-github-repo.sh  # Create repo
./scripts/04-terraform-provision.sh # AWS infra (10-15 min)
./scripts/05-build-docker-image.sh  # Build image
./scripts/06-login-ecr.sh           # ECR login
./scripts/07-push-to-ecr.sh         # Push image
./scripts/08-set-github-secrets.sh  # GitHub secrets
./scripts/09-git-push.sh            # Push code
./scripts/10-display-outputs.sh     # Show results
```

## Key Talking Points

1. **Architecture**: CloudFront → ALB → ECS Fargate (2 tasks)
2. **IP Detection**: Parses `X-Forwarded-For` header (first value = client IP)
3. **Security**: ECS in private subnets, only ALB exposed
4. **IaC**: Terraform manages all AWS resources
5. **CI/CD**: GitHub Actions auto-deploys on push to main
6. **Scalability**: Fargate auto-scales, ALB distributes load

## Demo Script

1. Run `./scripts/setup.sh`
2. Show progress through 10 steps
3. When complete, open CloudFront URL in browser
4. Show your IP address displayed
5. Open same URL on phone → Different IP shown
6. Show GitHub repo with automated workflow
7. Make code change, push → Auto-deploys

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Docker permission denied | `newgrp docker` |
| AWS not configured | Already done, should work |
| GitHub not auth | Already done, should work |
| Terraform fails | Re-run specific step script |
| Need to start over | `./scripts/cleanup.sh` then `./scripts/setup.sh` |

## Cleanup After Interview

```bash
./scripts/cleanup.sh  # Destroys all AWS resources
```

## Files to Highlight

- `app.py` - Flask app with IP extraction logic
- `terraform/` - Complete AWS infrastructure as code
- `.github/workflows/deploy.yml` - CI/CD pipeline
- `scripts/setup.sh` - Orchestrator for all automation

---

**✨ You're prepared! Trust the automation and explain your design decisions confidently.**
