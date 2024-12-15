terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

data "external" "env" {
  program = ["${path.module}/env.sh"]
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = data.external.env.result["os_username"]
  tenant_name = data.external.env.result["os_tenant_name"]
  password    = data.external.env.result["os_password"]
  auth_url    = data.external.env.result["os_auth_url"]
  region      = data.external.env.result["os_region_name"]
}

