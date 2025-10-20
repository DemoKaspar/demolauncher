# Fresh Todo App on AWS VM Fleet with PostgreSQL

This example demonstrates deploying a Fresh-based todo application on AWS VM fleet infrastructure with PostgreSQL database, including cost optimization scenarios.

## Quick Setup

```bash
# Using demolauncher pattern
APP_NAME="fresh-todo-app"
CLOUD="aws"
COMPUTE="vm-fleet"
RESOURCES=("postgres")
RUNNER="ecs-runner"
ORG_ID="unveiled-lunchroom-defame-ki2k"

# Follow demolauncher IMPLEMENTATION_GUIDE.md steps 1-7
```

## Architecture

- **Application**: Fresh TypeScript framework (Deno-based)
- **Compute**: AWS VM Fleet with load balancer
- **Database**: PostgreSQL on AWS RDS
- **Runner**: ECS Runner for deployments

## PostgreSQL Sizing Options

The setup creates two postgres modules for cost demonstration:

### Overprovisioned (Starting Point)
- **Instance**: `db.t3.small`
- **Storage**: 100GB (gp3)
- **Features**: Performance Insights enabled, 14-day backups
- **Use Case**: Initial deployment, performance testing

### Standard (Cost Optimized)
- **Instance**: `db.t3.micro`
- **Storage**: 20GB (gp2)
- **Features**: Basic monitoring, 7-day backups
- **Use Case**: Production after right-sizing

## Cost Optimization Demo

1. **Deploy with overprovisioned**: Start with `fresh-todo-app-postgres-overprovisioned`
2. **Monitor usage**: Demonstrate actual resource utilization
3. **Switch to standard**: Replace module rule with `fresh-todo-app-postgres-standard`
4. **Show savings**: Compare cost difference in video

## Deployment Manifest

```yaml
shared:
  compute:
    type: vm-fleet
  database:
    type: postgres

workloads:
  fresh-todo-app:
    variables:
      DATABASE_URL: "${shared.database.outputs.connection_string}"
      DB_HOST: "${shared.database.outputs.hostname}"
      DB_PORT: "${shared.database.outputs.port}"
      DB_NAME: "${shared.database.outputs.database}"
      DB_USER: "${shared.database.outputs.username}"
      DB_PASSWORD: "${shared.database.outputs.password}"
      LOAD_BALANCER_URL: "http://${shared.compute.outputs.loadbalancer_ip}"
```

## Application Repository

- **Source**: [Fresh Todo App](https://github.com/DemoKaspar/fresh-todo-app)
- **Container**: `ghcr.io/demokaspar/fresh-todo-app:latest`
- **Framework**: Fresh (Deno TypeScript)
- **Database**: PostgreSQL compatible

## Video Recording Notes

Perfect for demonstrating:
- Infrastructure as Code with Humanitec
- Database right-sizing and cost optimization
- Module switching for different environments
- Real-world cost savings scenarios