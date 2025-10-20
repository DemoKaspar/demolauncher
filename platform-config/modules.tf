# Terraform modules for postgres variants
resource "humanitec_module" "fresh_postgres_overprovisioned" {
  id          = "fresh-postgres-overprovisioned"
  name        = "fresh-postgres-overprovisioned"
  source_path = "git::https://github.com/DemoKaspar/humanitec-terraform-modules.git//postgres-overprovisioned"
  
  tags = {
    cost_profile = "high"
    tier        = "overprovisioned"
    managed_by  = "platform-team"
  }
}

resource "humanitec_module" "fresh_postgres_standard" {
  id          = "fresh-postgres-standard"  
  name        = "fresh-postgres-standard"
  source_path = "git::https://github.com/DemoKaspar/humanitec-terraform-modules.git//postgres-standard"
  
  tags = {
    cost_profile = "optimized"
    tier        = "standard"
    managed_by  = "platform-team"
  }
}

resource "humanitec_module" "vm_fleet_fresh" {
  id          = "vm-fleet-fresh"
  name        = "vm-fleet-fresh"
  source_path = "git::https://github.com/DemoKaspar/humanitec-terraform-modules.git//vm-fleet"
  
  tags = {
    compute_type = "ec2_load_balanced"
    managed_by   = "platform-team"
  }
}