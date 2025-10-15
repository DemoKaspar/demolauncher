#!/bin/bash
set -e

# Usage: ./setup-humanitec.sh APP_NAME CLOUD COMPUTE RESOURCES RUNNER
APP_NAME="$1"
CLOUD="$2"
COMPUTE="$3"
RESOURCES="$4"
RUNNER="$5"

# Sanitize app name for use as project ID
PROJECT_ID=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')

echo "=== Setting up Humanitec for $APP_NAME ==="
echo "Project ID: $PROJECT_ID"
echo "Cloud: $CLOUD"
echo "Compute: $COMPUTE"
echo "Resources: $RESOURCES"
echo "Runner: $RUNNER"

# Map runner to Humanitec environment type
case "$RUNNER" in
  "ecs-runner")
    ENV_TYPE="humanitec-11wcie-development"
    ORG_EXAMPLE="unveiled-lunchroom-defame-ki2k"
    ;;
  "gke-runner")
    ENV_TYPE="humanitec-gcp-development"
    ORG_EXAMPLE="your-gcp-org"
    ;;
  "aci-runner")
    ENV_TYPE="humanitec-azure-development"
    ORG_EXAMPLE="your-azure-org"
    ;;
  *)
    echo "Unknown runner: $RUNNER"
    exit 1
    ;;
esac

# Create project
echo "Creating project $PROJECT_ID..."
hctl create project "$PROJECT_ID" || echo "Project may already exist"

# Create development environment
echo "Creating development environment..."
hctl create environment "$PROJECT_ID" dev --set env_type_id="$ENV_TYPE" || echo "Environment may already exist"

# Create compute module
echo "Creating $COMPUTE module..."
COMPUTE_MODULE_ID="${PROJECT_ID}-${COMPUTE}"
hctl create module "$COMPUTE_MODULE_ID" \
  --set resource_type="$COMPUTE" \
  --set module_source="git::https://github.com/YOUR_ORG/infrastructure-templates.git//templates/$CLOUD/$COMPUTE" \
  --set description="$COMPUTE infrastructure for $APP_NAME"

hctl create module-rule --set module_id="$COMPUTE_MODULE_ID" --set project_id="$PROJECT_ID"

# Create resource modules
if [ -n "$RESOURCES" ]; then
  IFS=',' read -ra RESOURCE_ARRAY <<< "$RESOURCES"
  for RESOURCE in "${RESOURCE_ARRAY[@]}"; do
    echo "Creating $RESOURCE module..."
    RESOURCE_MODULE_ID="${PROJECT_ID}-${RESOURCE}"
    hctl create module "$RESOURCE_MODULE_ID" \
      --set resource_type="$RESOURCE" \
      --set module_source="git::https://github.com/YOUR_ORG/infrastructure-templates.git//templates/$CLOUD/resources/$RESOURCE" \
      --set description="$RESOURCE resource for $APP_NAME"
    
    hctl create module-rule --set module_id="$RESOURCE_MODULE_ID" --set project_id="$PROJECT_ID"
  done
fi

echo ""
echo "=== Humanitec Setup Complete ==="
echo "Organization: $ORG_EXAMPLE (update this in your .env)"
echo "Project: $PROJECT_ID"
echo "Environment: dev"
echo ""
echo "Next steps:"
echo "1. Update your GitHub Actions workflow with HUMANITEC_ORG=$ORG_EXAMPLE"
echo "2. Update PROJECT_ID=$PROJECT_ID"
echo "3. Create deployment.yaml with the appropriate manifest"
echo "4. Push to trigger deployment"