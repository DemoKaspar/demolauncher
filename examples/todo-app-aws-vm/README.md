# Example: Todo App on AWS VM Fleet

This example demonstrates how to deploy a todo application on AWS using VM fleet with PostgreSQL database.

## Request Format
```
Use this repo and spin up a todo app on AWS, use vm-fleet and enable the following postgres in the Orchestrator, also use the ecs-runner to do this and GitHub Actions workflows.
```

## Generated Configuration

### Project Structure
```
todo-app/
├── .github/workflows/deploy.yml    # GitHub Actions workflow
├── deployment.yaml                 # Humanitec deployment manifest  
├── Dockerfile                     # Container definition
├── package.json                   # Node.js dependencies
├── server.js                      # Application code
└── public/                        # Static assets
```

### Deployment Manifest
```yaml
shared:
  compute:
    type: vm-fleet
  database:
    type: postgres

workloads:
  todo-app:
    variables:
      LOAD_BALANCER_URL: "http://${shared.compute.outputs.loadbalancer_ip}"
      DATABASE_URL: "${shared.database.outputs.connection_string}"
      DB_HOST: "${shared.database.outputs.hostname}"
      DB_PORT: "${shared.database.outputs.port}"
      DB_NAME: "${shared.database.outputs.database}"
      DB_USER: "${shared.database.outputs.username}"
      DB_PASSWORD: "${shared.database.outputs.password}"
```

### GitHub Actions Environment Variables
```yaml
env:
  HUMANITEC_ORG: unveiled-lunchroom-defame-ki2k
  PROJECT_ID: todo-app
  ENVIRONMENT_ID: dev
```

### Required Secrets
- `HUMANITEC_TOKEN` - Humanitec API token
- `GITHUB_TOKEN` - Automatically provided for container registry access

## Infrastructure Provisioned

### AWS Resources
- **Auto Scaling Group** with 2-4 t3.micro instances
- **Application Load Balancer** with health checks
- **RDS PostgreSQL** instance (db.t3.micro)
- **Security Groups** for proper network isolation
- **VPC resources** in default VPC

### Humanitec Resources
- **Project**: `todo-app`
- **Environment**: `dev` (using ecs-runner)
- **Modules**: 
  - `todo-app-vm-fleet` (compute infrastructure)
  - `todo-app-postgres` (database)

## Result
- ✅ Todo application running on AWS VMs
- ✅ PostgreSQL database connected
- ✅ Load balancer accessible from internet
- ✅ Auto-scaling enabled (2-4 instances)
- ✅ Health checks configured
- ✅ CI/CD pipeline working

**Access**: Application available at load balancer DNS name on port 80
**Time to deploy**: ~5-8 minutes from GitHub Actions trigger