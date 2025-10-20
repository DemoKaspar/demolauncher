terraform {
  required_providers {
    humanitec = {
      source  = "humanitec/humanitec"
      version = "~> 1.0"
    }
  }
}

# Configure the Humanitec Provider
provider "humanitec" {
  org_id = "unveiled-lunchroom-defame-ki2k"
}