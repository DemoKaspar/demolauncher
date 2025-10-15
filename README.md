# Infrastructure Templates for Humanitec Platform Orchestrator

## 🚀 Quick Start for Claude

When a user asks to create infrastructure, use this template:

```
Use this repo and spin up a [APP_NAME] on [CLOUD_PROVIDER], use [COMPUTE_TYPE] and enable the following [RESOURCES] in the Orchestrator, also use the [RUNNER] to do this and GitHub Actions workflows.
```

**Example**:
> Use this repo and spin up a todo app on AWS, use vm-fleet and enable the following postgres,s3 in the Orchestrator, also use the ecs-runner to do this and GitHub Actions workflows.

## 📋 Supported Configurations

### Cloud Providers
- `aws` - Amazon Web Services
- `gcp` - Google Cloud Platform  
- `azure` - Microsoft Azure

### Compute Types
- `vm-fleet` - Auto Scaling Group + Load Balancer
- `serverless` - Lambda/Cloud Functions + API Gateway
- `kubernetes` - EKS/GKE/AKS cluster
- `containers` - ECS/Cloud Run/Container Instances

### Resources  
- `postgres` - Managed PostgreSQL database
- `mysql` - Managed MySQL database
- `redis` - Managed Redis cache
- `s3` - Object storage (S3/Cloud Storage/Blob Storage)
- `secrets` - Secret management service
- `dns` - DNS and domain management
- `monitoring` - CloudWatch/Stackdriver/Application Insights

### Runners
- `ecs-runner` - ECS-based runner (AWS)
- `gke-runner` - GKE-based runner (GCP)
- `aci-runner` - Container Instance runner (Azure)

## 🎯 Implementation Process

### Phase 1: Parse Requirements (30 seconds)
1. Extract app name, cloud provider, compute type, resources, and runner
2. Set environment variables for the setup

### Phase 2: Terraform Modules (2 minutes)
1. Copy appropriate Terraform templates from `/templates/[cloud]/[compute]`
2. Add resource modules from `/templates/[cloud]/resources/[resource]`
3. Customize outputs for workload connections

### Phase 3: Humanitec Setup (1 minute)
1. Create project with sanitized app name
2. Create development environment
3. Create and configure modules with rules

### Phase 4: CI/CD Pipeline (1 minute)
1. Copy GitHub Actions workflow from `/workflows/[cloud]-[compute].yml`
2. Configure secrets and environment variables
3. Create deployment manifest

### Phase 5: Deploy & Verify (5 minutes)
1. Trigger GitHub Actions workflow
2. Monitor deployment logs
3. Provide connection details and next steps

## 📁 Repository Structure

```
infrastructure-templates/
├── README.md                           # This file
├── templates/                          # Terraform templates
│   ├── aws/
│   │   ├── vm-fleet/                  # EC2 ASG + ALB
│   │   ├── serverless/                # Lambda + API Gateway
│   │   ├── kubernetes/                # EKS cluster
│   │   └── resources/
│   │       ├── postgres/              # RDS PostgreSQL
│   │       ├── s3/                    # S3 bucket
│   │       ├── redis/                 # ElastiCache Redis
│   │       └── secrets/               # AWS Secrets Manager
│   ├── gcp/
│   │   ├── vm-fleet/                  # Compute Engine + Load Balancer
│   │   ├── serverless/                # Cloud Functions + API Gateway
│   │   └── resources/
│   │       ├── postgres/              # Cloud SQL PostgreSQL
│   │       ├── storage/               # Cloud Storage
│   │       └── secrets/               # Secret Manager
│   └── azure/
│       ├── vm-fleet/                  # VM Scale Sets + Load Balancer
│       ├── serverless/                # Azure Functions + API Management
│       └── resources/
│           ├── postgres/              # Azure Database for PostgreSQL
│           ├── storage/               # Blob Storage
│           └── secrets/               # Key Vault
├── workflows/                          # GitHub Actions templates
│   ├── aws-vm-fleet.yml
│   ├── aws-serverless.yml
│   ├── gcp-vm-fleet.yml
│   └── azure-vm-fleet.yml
├── deployment-manifests/               # Humanitec deployment templates
│   ├── vm-fleet-basic.yaml
│   ├── vm-fleet-with-database.yaml
│   ├── serverless-basic.yaml
│   └── full-stack.yaml
├── scripts/                           # Automation scripts
│   ├── setup-humanitec.sh
│   ├── create-project.sh
│   └── configure-secrets.sh
└── examples/                          # Complete working examples
    ├── todo-app-aws-vm/
    ├── api-service-gcp-serverless/
    └── full-stack-azure/
```

## 🔧 Template Standards

### Terraform Module Requirements
1. **Self-contained** - No input variables
2. **Standardized outputs** - Follow naming convention below
3. **Resource tagging** - Include app_id, env_id, created_by tags
4. **Security best practices** - Least privilege IAM, encrypted storage

### Standard Output Names
```terraform
# Compute resources
output "loadbalancer_ip" { value = "..." }
output "ssh_private_key" { value = "..." }
output "instance_ips" { value = [...] }

# Database resources  
output "connection_string" { value = "..." }
output "hostname" { value = "..." }
output "port" { value = 5432 }
output "database" { value = "..." }
output "username" { value = "..." }
output "password" { value = "..." }

# Storage resources
output "bucket_name" { value = "..." }
output "bucket_url" { value = "..." }
output "access_key_id" { value = "..." }
output "secret_access_key" { value = "..." }
```

### Deployment Manifest Patterns
```yaml
# Basic pattern
shared:
  compute:
    type: [compute-type]
  database:
    type: postgres
  storage:
    type: s3

workloads:
  [app-name]:
    variables:
      DATABASE_URL: "${shared.database.outputs.connection_string}"
      S3_BUCKET: "${shared.storage.outputs.bucket_name}"
      LOAD_BALANCER_URL: "${shared.compute.outputs.loadbalancer_ip}"
```

## 🚨 Common Pitfalls to Avoid

1. **Don't use Terraform variables** - Humanitec can't pass complex parameters reliably
2. **Don't mix Score and Humanitec manifests** - Use Humanitec deployment manifests only
3. **Don't parameterize environment differences** - Use separate infrastructure per environment
4. **Don't forget resource connections** - Always reference shared resources in workloads
5. **Don't use complex placeholder syntax** - Stick to `${shared.resource.outputs.property}`

## 📖 Reference Commands

### Humanitec CLI Commands
```bash
# Project setup
hctl create project [PROJECT_ID]
hctl create environment [PROJECT_ID] dev --set env_type_id=[RUNNER]

# Module setup  
hctl create module [MODULE_ID] --set resource_type=[TYPE] --set module_source=[GIT_URL]
hctl create module-rule --set module_id=[MODULE_ID] --set project_id=[PROJECT_ID]

# Deployment
hctl deploy [PROJECT_ID] dev deployment.yaml --no-prompt
```

### GitHub Actions Secrets Required
```
HUMANITEC_TOKEN - Humanitec API token
AWS_ACCESS_KEY_ID - AWS access key (for AWS)
AWS_SECRET_ACCESS_KEY - AWS secret key (for AWS)  
GOOGLE_CREDENTIALS - GCP service account JSON (for GCP)
AZURE_CREDENTIALS - Azure service principal JSON (for Azure)
```

## ✅ Success Criteria

A successful setup should result in:
1. ✅ Infrastructure deployed and accessible
2. ✅ Application workload running
3. ✅ Resources properly connected (database, storage, etc.)
4. ✅ Humanitec graph showing all connections
5. ✅ GitHub Actions pipeline working end-to-end
6. ✅ Load balancer URL accessible with deployed application

Total time from prompt to working application: **5-10 minutes**