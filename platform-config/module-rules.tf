# Module rules for fresh-todo-app-project-clean
# These rules determine which modules are used for each resource type

resource "humanitec_module_rule" "fresh_todo_postgres" {
  module_id = humanitec_module.fresh_postgres_standard.id  # Changed by Cortex policy
  
  project_id     = "fresh-todo-app-project-clean"
  resource_type  = "postgres"
  resource_class = "default"
  
  tags = {
    project           = "fresh-todo-app"
    environment       = "dev"
    cost_tier         = "optimized"  # Changed from "high" 
    reason            = "cortex-cost-optimization-policy"  # Updated reason
    policy_trigger    = "utilization-below-30pct-7days"
    enforcement_date  = "2025-10-20T11:56:48Z"
    estimated_savings = "60-percent-cost-reduction"
    changed_by        = "cortex-policy-engine"
  }
}

resource "humanitec_module_rule" "fresh_todo_vm_fleet" {
  module_id = humanitec_module.vm_fleet_fresh.id
  
  project_id     = "fresh-todo-app-project-clean" 
  resource_type  = "vm-fleet"
  resource_class = "default"
  
  tags = {
    project     = "fresh-todo-app"
    environment = "dev"
    compute     = "standard"
  }
}