# 🚀 Claude Infrastructure Templates - Quick Setup Guide

## When you see a request like this:

> "Use this repo and spin up a **todo app** on **AWS**, use **vm-fleet** and enable the following **postgres,s3** in the Orchestrator, also use the **ecs-runner** to do this and **GitHub Actions** workflows."

## Follow this exact process:

### 1. Extract Parameters (10 seconds)
```
APP_NAME = "todo app" → "todo-app"
CLOUD = "AWS" → "aws"  
COMPUTE = "vm-fleet"
RESOURCES = "postgres,s3" → ["postgres", "s3"]
RUNNER = "ecs-runner"
```

### 2. Set up the project structure (60 seconds)
```bash
# Create Terraform modules by copying from templates
cp -r templates/aws/vm-fleet/* terraform-modules/compute/
cp -r templates/aws/resources/postgres/* terraform-modules/postgres/  
cp -r templates/aws/resources/s3/* terraform-modules/s3/

# Create deployment manifest
cp deployment-manifests/full-stack.yaml deployment.yaml
sed -i "s/APP_NAME_PLACEHOLDER/todo-app/g" deployment.yaml

# Create GitHub Actions workflow
cp workflows/aws-vm-fleet.yml .github/workflows/deploy.yml
```

### 3. Configure Humanitec (90 seconds)
```bash
# Set organization based on runner
ORG_ID="unveiled-lunchroom-defame-ki2k"  # for ecs-runner
ENV_TYPE="humanitec-11wcie-development"

# Create project
PROJECT_ID="todo-app"
hctl create project $PROJECT_ID
hctl create environment $PROJECT_ID dev --set env_type_id=$ENV_TYPE

# Create modules (self-contained, no parameters!)
hctl create module todo-app-vm-fleet \
  --set resource_type=vm-fleet \
  --set module_source="git://github.com/USER/infrastructure-templates.git//templates/aws/vm-fleet"

hctl create module todo-app-postgres \
  --set resource_type=postgres \
  --set module_source="git://github.com/USER/infrastructure-templates.git//templates/aws/resources/postgres"

hctl create module todo-app-s3 \
  --set resource_type=s3 \
  --set module_source="git://github.com/USER/infrastructure-templates.git//templates/aws/resources/s3"

# Create module rules (project-specific)
hctl create module-rule --set module_id=todo-app-vm-fleet --set project_id=$PROJECT_ID
hctl create module-rule --set module_id=todo-app-postgres --set project_id=$PROJECT_ID  
hctl create module-rule --set module_id=todo-app-s3 --set project_id=$PROJECT_ID
```

### 4. Final deployment.yaml should look like:
```yaml
shared:
  compute:
    type: vm-fleet
  database:
    type: postgres
  storage:
    type: s3

workloads:
  todo-app:
    variables:
      LOAD_BALANCER_URL: "http://${shared.compute.outputs.loadbalancer_ip}"
      DATABASE_URL: "${shared.database.outputs.connection_string}"
      S3_BUCKET: "${shared.storage.outputs.bucket_name}"
      AWS_ACCESS_KEY_ID: "${shared.storage.outputs.access_key_id}"
      AWS_SECRET_ACCESS_KEY: "${shared.storage.outputs.secret_access_key}"
```

### 5. Deploy and verify (5-8 minutes)
```bash
# Test locally first
hctl deploy todo-app dev deployment.yaml --no-prompt

# Then push to trigger GitHub Actions
git add . && git commit -m "Deploy todo app with postgres and s3"
git push origin main

# Monitor deployment
gh run watch
```

## 🎯 Success Criteria:
- ✅ Application accessible via load balancer URL
- ✅ Humanitec graph shows: workload → compute + database + storage  
- ✅ GitHub Actions pipeline completes successfully
- ✅ All resources provisioned in AWS
- ✅ Total time: **5-10 minutes**

## 📋 Supported Configurations:

| Cloud | Compute Types | Resources | Runners |
|-------|--------------|-----------|---------|
| `aws` | `vm-fleet`, `serverless` | `postgres`, `mysql`, `redis`, `s3`, `secrets` | `ecs-runner` |
| `gcp` | `vm-fleet`, `serverless` | `postgres`, `mysql`, `redis`, `storage`, `secrets` | `gke-runner` |
| `azure` | `vm-fleet`, `serverless` | `postgres`, `mysql`, `redis`, `storage`, `secrets` | `aci-runner` |

## ⚡ Key Rules:
1. **Always use self-contained Terraform modules** (no variables)
2. **Connect resources via output references** in deployment.yaml
3. **Use appropriate runner** for organization mapping
4. **Test locally first** before pushing to GitHub Actions  
5. **Keep module names unique** with app prefix

## 🔧 Common Patterns:

**Basic compute only:**
```yaml
shared:
  compute:
    type: vm-fleet
```

**With database:**
```yaml
shared:
  compute:
    type: vm-fleet
  database:
    type: postgres
```

**Full stack:**
```yaml
shared:
  compute:
    type: vm-fleet
  database:
    type: postgres
  storage:
    type: s3
```

This template enables **any infrastructure request** to be deployed in **5-10 minutes** with a single prompt! 🚀