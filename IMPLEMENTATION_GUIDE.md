# Claude Implementation Guide

When a user provides a request like:
> "Use this repo and spin up a [APP_NAME] on [CLOUD], use [COMPUTE] and enable the following [RESOURCES] in the Orchestrator, also use the [RUNNER] to do this and GitHub Actions workflows."

Follow this exact process:

## Step 1: Parse and Validate (30 seconds)

```python
# Extract components
APP_NAME = "todo-app"
CLOUD = "aws"  # aws, gcp, azure
COMPUTE = "vm-fleet"  # vm-fleet, serverless, kubernetes
RESOURCES = ["postgres", "s3"]  # postgres, mysql, redis, s3, secrets, dns
# Note: postgres creates both overprovisioned and standard versions for cost demos
RUNNER = "ecs-runner"  # ecs-runner, gke-runner, aci-runner

# Validate combinations
VALID_COMBINATIONS = {
    "aws": ["vm-fleet", "serverless", "kubernetes"],
    "gcp": ["vm-fleet", "serverless", "kubernetes"], 
    "azure": ["vm-fleet", "serverless", "kubernetes"]
}
```

## Step 2: Create Project Structure (1 minute)

```bash
# 1. Create project directory
mkdir ${APP_NAME}
cd ${APP_NAME}

# 2. Copy base application files (if they don't exist)
cp templates/base-app/* .

# 3. Copy Terraform modules
mkdir -p terraform-modules
cp -r templates/${CLOUD}/${COMPUTE} terraform-modules/
for resource in ${RESOURCES}; do
    cp -r templates/${CLOUD}/resources/${resource} terraform-modules/
done
```

## Step 3: Configure Humanitec (2 minutes)

```bash
# 1. Set project variables
PROJECT_ID=$(echo ${APP_NAME} | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g')

# 2. Create project and environment
hctl create project ${PROJECT_ID}
hctl create environment ${PROJECT_ID} dev --set env_type_id=${RUNNER_ENV_TYPE}

# 3. Create modules
hctl create module ${PROJECT_ID}-${COMPUTE} \
  --set resource_type=${COMPUTE} \
  --set module_source="git::https://github.com/DemoKaspar/humanitec-terraform-modules.git//${COMPUTE}"

for resource in ${RESOURCES}; do
  # For postgres, create both overprovisioned and standard versions for downsizing demos
  if [[ ${resource} == "postgres" ]]; then
    hctl create module ${PROJECT_ID}-postgres-overprovisioned \
      --set resource_type=postgres \
      --set module_source="git::https://github.com/DemoKaspar/humanitec-terraform-modules.git//postgres-overprovisioned"
    hctl create module ${PROJECT_ID}-postgres-standard \
      --set resource_type=postgres \
      --set module_source="git::https://github.com/DemoKaspar/humanitec-terraform-modules.git//postgres-standard"
  else
    hctl create module ${PROJECT_ID}-${resource} \
      --set resource_type=${resource} \
      --set module_source="git::https://github.com/DemoKaspar/humanitec-terraform-modules.git//resources/${resource}"
  fi
done

# 4. Create module rules
hctl create module-rule --set module_id=${PROJECT_ID}-${COMPUTE} --set project_id=${PROJECT_ID}
for resource in ${RESOURCES}; do
  # For postgres, start with overprovisioned version (can be switched to standard later for cost demos)
  if [[ ${resource} == "postgres" ]]; then
    hctl create module-rule --set module_id=${PROJECT_ID}-postgres-overprovisioned --set project_id=${PROJECT_ID}
  else
    hctl create module-rule --set module_id=${PROJECT_ID}-${resource} --set project_id=${PROJECT_ID}
  fi
done
```

## Step 4: Create Deployment Manifest (1 minute)

```bash
# Select appropriate template based on resources
if [[ ${RESOURCES} == *"postgres"* && ${RESOURCES} == *"s3"* ]]; then
    TEMPLATE="full-stack.yaml"
elif [[ ${RESOURCES} == *"postgres"* ]]; then
    TEMPLATE="vm-fleet-with-database.yaml"
else
    TEMPLATE="vm-fleet-basic.yaml"
fi

# Copy and customize
cp deployment-manifests/${TEMPLATE} deployment.yaml
sed -i "s/APP_NAME_PLACEHOLDER/${APP_NAME}/g" deployment.yaml
sed -i "s/vm-fleet/${COMPUTE}/g" deployment.yaml
```

## Step 5: Create GitHub Actions Workflow (1 minute)

```bash
# Create workflow directory
mkdir -p .github/workflows

# Copy appropriate workflow template
cp workflows/${CLOUD}-${COMPUTE}.yml .github/workflows/deploy.yml

# Update placeholders
sed -i "s/# TO_BE_REPLACED/${ORG_ID}/g" .github/workflows/deploy.yml
sed -i "s/PROJECT_ID: # TO_BE_REPLACED/PROJECT_ID: ${PROJECT_ID}/g" .github/workflows/deploy.yml
```

## Step 6: Runner and Organization Mapping

```bash
# Map runner to org and env type
case ${RUNNER} in
  "ecs-runner")
    ORG_ID="unveiled-lunchroom-defame-ki2k"
    ENV_TYPE="humanitec-11wcie-development"
    ;;
  "gke-runner")
    ORG_ID="your-gcp-org"
    ENV_TYPE="humanitec-gcp-development" 
    ;;
  "aci-runner")
    ORG_ID="your-azure-org"
    ENV_TYPE="humanitec-azure-development"
    ;;
esac
```

## Step 7: Deploy and Verify (5 minutes)

```bash
# 1. Deploy locally to test
hctl deploy ${PROJECT_ID} dev deployment.yaml --no-prompt

# 2. Set up GitHub repository (if needed)
git init
git add .
git commit -m "Initial infrastructure setup for ${APP_NAME}"

# 3. Push to trigger pipeline
git push origin main

# 4. Monitor deployment
gh run watch
```

## Success Checklist

✅ **Humanitec project created with correct modules**  
✅ **GitHub Actions workflow configured and running**  
✅ **Infrastructure deploying successfully**  
✅ **Application accessible via load balancer**  
✅ **All resources connected (database, storage, etc.)**  
✅ **Humanitec graph showing proper dependencies**  

## Error Handling

### Common Issues:
1. **Module parameter errors** → Use self-contained modules
2. **Authentication failures** → Check HUMANITEC_TOKEN secret
3. **Resource conflicts** → Use unique random IDs
4. **Deployment timeouts** → Check AWS quotas/limits

### Debug Commands:
```bash
# Check module status
hctl get module ${MODULE_ID}

# Check deployment logs  
hctl get deployments ${PROJECT_ID} dev --limit 1

# Check resource status
hctl get environment ${PROJECT_ID} dev
```

## Time Target: 5-10 minutes total
- Setup: 4-5 minutes
- AWS provisioning: 3-5 minutes  
- Verification: 1 minute