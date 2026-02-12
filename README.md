# AWS ECS Interview Application

A simple web application deployed to AWS ECS Fargate behind an Application Load Balancer and CloudFront CDN. The app displays the client's IP address by parsing the `X-Forwarded-For` header.

## Architecture

```
Client → CloudFront Distribution → Application Load Balancer → ECS Service (2 tasks) → Flask App
```

**Flow:**
- Client requests reach CloudFront distribution
- CloudFront forwards to ALB (HTTP)
- ALB distributes traffic to ECS Fargate tasks running in private subnets
- Flask application extracts client IP from `X-Forwarded-For` header
- Response flows back through ALB and CloudFront to client

## Prerequisites

Ensure the following tools are installed and configured:

- **Git** - Version control
- **Docker** - Container runtime (daemon must be running)
- **Terraform** - Infrastructure as Code (v1.0+)
- **AWS CLI** - AWS command-line interface
- **GitHub CLI (gh)** - GitHub automation
- **AWS Account** - With appropriate IAM permissions
- **GitHub Account** - For repository and CI/CD

## Quick Start

### 1. Configure Credentials

**AWS CLI:**
```bash
aws configure
```
Enter your AWS credentials:
- Access Key ID
- Secret Access Key
- Region: `us-east-1`
- Output format: `json`

**GitHub CLI:**
```bash
gh auth login
```

### 2. Run Automated Setup

Execute the master setup script:
```bash
./scripts/setup.sh
```

This single command will:
1. ✅ Check all prerequisites
2. ✅ Initialize git repository
3. ✅ Create GitHub repository
4. ✅ Provision AWS infrastructure (10-15 minutes)
5. ✅ Build Docker image
6. ✅ Login to Amazon ECR
7. ✅ Push image to ECR
8. ✅ Configure GitHub secrets
9. ✅ Push code to GitHub (triggers first deployment)
10. ✅ Display CloudFront URL

**Estimated time:** 15-20 minutes

### 3. Access Your Application

After setup completes, the CloudFront URL will be displayed:
```
https://d1234567890abc.cloudfront.net
```

Open this URL in your browser to see your public IP address!

## Manual Step-by-Step Execution

If you prefer to run each step individually:

```bash
./scripts/01-check-prerequisites.sh     # Verify tools and authentication
./scripts/02-init-git.sh                # Initialize git
./scripts/03-create-github-repo.sh      # Create GitHub repo
./scripts/04-terraform-provision.sh     # Provision AWS (takes 10-15 min)
./scripts/05-build-docker-image.sh      # Build Docker image
./scripts/06-login-ecr.sh               # Login to ECR
./scripts/07-push-to-ecr.sh             # Push image to ECR
./scripts/08-set-github-secrets.sh      # Set GitHub secrets
./scripts/09-git-push.sh                # Push to GitHub
./scripts/10-display-outputs.sh         # Show outputs
```

## Local Development

### Run Flask App Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Run the application
python app.py
```

Visit `http://localhost:8080` - you should see `127.0.0.1` (localhost IP).

### Test with Docker Locally

```bash
# Build the Docker image
docker build -t interview-app .

# Run the container
docker run -p 8080:8080 interview-app
```

Visit `http://localhost:8080` to test.

## Client IP Detection

The application determines the client's IP address using the following logic:

### Header Chain
When a request flows through CloudFront → ALB → ECS:

1. **Client** makes request with original IP: `203.0.113.45`
2. **CloudFront** adds: `X-Forwarded-For: 203.0.113.45`
3. **ALB** appends its IP: `X-Forwarded-For: 203.0.113.45, 192.0.2.100`
4. **App** receives: `X-Forwarded-For: 203.0.113.45, 192.0.2.100`

### Extraction Logic (app.py)

```python
x_forwarded_for = request.headers.get('X-Forwarded-For')

if x_forwarded_for:
    # Take the FIRST IP (original client)
    client_ip = x_forwarded_for.split(',')[0].strip()
else:
    # Fallback to remote_addr if header missing
    client_ip = request.remote_addr
```

**Key Point:** The first IP in the comma-separated list is the original client IP. Subsequent IPs are proxies in the chain.

## Infrastructure Details

### AWS Resources Created

**Networking:**
- VPC (10.0.0.0/16)
- 2 Public subnets (for ALB)
- 2 Private subnets (for ECS tasks)
- Internet Gateway
- NAT Gateway
- Route tables

**Compute:**
- ECR repository (Docker images)
- ECS Fargate cluster
- ECS service (2 tasks, 256 CPU, 512 MB memory)
- Task definition (runs Flask app on port 8080)

**Load Balancing:**
- Application Load Balancer (public)
- Target group (health checks on `/`)
- HTTP listener (port 80)

**CDN:**
- CloudFront distribution
- Origin: ALB
- Cache disabled (TTL=0) for real-time IP updates
- Forwards `X-Forwarded-For` header

**Security:**
- ALB Security Group: Allow 80/443 from anywhere
- ECS Security Group: Allow 8080 from ALB only

### Terraform Outputs

View deployment details anytime:
```bash
./scripts/10-display-outputs.sh
```

Or directly with Terraform:
```bash
cd terraform
terraform output
```

## GitHub Actions CI/CD

The workflow (`.github/workflows/deploy.yml`) triggers on every push to `main`:

**Steps:**
1. Checkout code
2. Configure AWS credentials
3. Login to ECR
4. Build Docker image (tags: `$GITHUB_SHA` and `latest`)
5. Push both tags to ECR
6. Download current ECS task definition
7. Update task definition with new image
8. Deploy to ECS (waits for service stability)
9. Invalidate CloudFront cache

**GitHub Secrets (automatically configured):**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `ECR_REPOSITORY`
- `ECS_CLUSTER`
- `ECS_SERVICE`
- `ECS_TASK_DEFINITION`
- `CONTAINER_NAME`
- `CLOUDFRONT_DISTRIBUTION_ID`

## Verification

### 1. Test the Application

Access the CloudFront URL from different networks:
```bash
# From your computer
curl https://YOUR-CLOUDFRONT-URL.cloudfront.net

# Check from different location (phone, VPN) to see different IPs
```

### 2. Check ECS Service

```bash
aws ecs describe-services \
  --cluster interview-app-cluster \
  --services interview-app-service \
  --region us-east-1
```

Verify `runningCount: 2` and `desiredCount: 2`.

### 3. Check Target Group Health

Go to AWS Console:
- EC2 → Target Groups → `interview-app-tg`
- Check that 2 targets show "healthy" status

### 4. View GitHub Actions

```bash
gh repo view --web
```

Go to "Actions" tab to see deployment runs.

### 5. Check Logs

```bash
aws logs tail /ecs/interview-app-prod --follow --region us-east-1
```

## Troubleshooting

### Issue: Docker daemon not running
```bash
sudo service docker start
```

### Issue: Terraform state locked
```bash
cd terraform
terraform force-unlock LOCK_ID
```

### Issue: ECS tasks not starting
Check logs:
```bash
aws logs tail /ecs/interview-app-prod --since 1h --region us-east-1
```

Common causes:
- ECR image not found (ensure step 7 completed)
- Task execution role permissions
- Security group blocking traffic

### Issue: ALB health checks failing
- Verify app responds on port 8080
- Check ECS task security group allows traffic from ALB
- Verify target group health check path is `/`

### Issue: CloudFront shows wrong IP
- CloudFront may cache responses (but TTL is 0)
- Force invalidation:
```bash
aws cloudfront create-invalidation \
  --distribution-id YOUR_DIST_ID \
  --paths "/*"
```

### Issue: GitHub Actions workflow fails
- Check GitHub secrets are set correctly
- Verify AWS credentials have necessary permissions
- Check workflow run details in GitHub Actions tab

## Cleanup

To destroy all AWS resources:

```bash
./scripts/cleanup.sh
```

**Warning:** This will:
- Destroy CloudFront distribution (~15 min)
- Delete ALB, ECS cluster, VPC
- Remove ECR repository and all images
- Optionally delete GitHub repository

## Project Structure

```
.
├── app.py                          # Flask application
├── requirements.txt                # Python dependencies
├── Dockerfile                      # Container build
├── .gitignore                      # Git exclusions
├── README.md                       # This file
├── .github/
│   └── workflows/
│       └── deploy.yml              # GitHub Actions CI/CD
├── terraform/                      # Infrastructure as Code
│   ├── main.tf                     # Provider config
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Output values
│   ├── ecr.tf                      # ECR repository
│   ├── vpc.tf                      # VPC and networking
│   ├── security-groups.tf          # Security groups
│   ├── iam.tf                      # IAM roles
│   ├── alb.tf                      # Load balancer
│   ├── ecs.tf                      # ECS cluster/service
│   └── cloudfront.tf               # CDN distribution
└── scripts/                        # Automation scripts
    ├── setup.sh                    # Master orchestrator
    ├── cleanup.sh                  # Teardown script
    ├── 01-check-prerequisites.sh   # Verify tools
    ├── 02-init-git.sh              # Git initialization
    ├── 03-create-github-repo.sh    # Create repo
    ├── 04-terraform-provision.sh   # Provision AWS
    ├── 05-build-docker-image.sh    # Build image
    ├── 06-login-ecr.sh             # ECR login
    ├── 07-push-to-ecr.sh           # Push to ECR
    ├── 08-set-github-secrets.sh    # Configure secrets
    ├── 09-git-push.sh              # Push to GitHub
    └── 10-display-outputs.sh       # Show results
```

## Technologies Used

- **Python 3.11** - Runtime
- **Flask** - Web framework
- **Gunicorn** - WSGI server
- **Docker** - Containerization
- **Terraform** - Infrastructure as Code
- **AWS ECS Fargate** - Serverless containers
- **AWS ALB** - Load balancing
- **AWS CloudFront** - CDN
- **AWS ECR** - Container registry
- **GitHub Actions** - CI/CD pipeline

## License

This is an interview project. Use freely.

## Author

Interview Candidate
