# Module rules for fresh-todo-app-project-clean
# These rules determine which modules are used for each resource type

resource "humanitec_module_rule" "fresh_todo_postgres" {
  module_id = humanitec_module.fresh_postgres_overprovisioned.id
  
  project_id     = "fresh-todo-app-project-clean"
  resource_type  = "postgres"
  resource_class = "default"
  
  tags = {
    project     = "fresh-todo-app"
    environment = "dev"
    cost_tier   = "high"
    reason      = "initial-deployment-overprovisioned"
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