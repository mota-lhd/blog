terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.40.0"
    }
  }

  cloud {
    organization = "kraggin"

    workspaces {
      name = "personal-blog"
    }
  }
}

provider "google" {
  # Configuration options
  region  = var.location
  project = var.project_id
}

resource "google_project_service" "default_services" {
  project = var.project_id

  for_each = toset(var.gcp_api_to_activate)

  service                    = each.key
  disable_dependent_services = true
}

module "iam" {
  source                   = "./modules/iam"
  project_id               = var.project_id
  location                 = var.location
  github_org_url           = var.github_org_url
  repo_name                = var.repo_name
  main_custom_role_perms   = var.main_custom_role_perms
  main_impersonate_account = var.main_impersonate_account
  main_sa_roles            = var.main_sa_roles
}

module "dns" {
  source      = "./modules/net"
  project_id  = var.project_id
  main_domain = var.main_domain
}

module "backend-data" {
  source     = "./modules/data"
  project_id = var.project_id
  location   = var.location
}

module "backend" {
  source           = "./modules/back"
  project_id       = var.project_id
  location         = var.location
  backend_sa_email = module.backend-data.backend_sa_email
}

module "frontend" {
  source     = "./modules/front"
  project_id = var.project_id
  location   = var.location
}

module "run-mappings" {
  source                 = "./modules/mappings"
  project_id             = var.project_id
  location               = var.location
  main_domain            = var.main_domain
  front_cloud_run_name   = module.frontend.cloud_run_name
  backend_cloud_run_name = module.backend.cloud_run_name
  managed_zone_name      = module.dns.managed_zone_name
}

module "dns-records" {
  source            = "./modules/records"
  project_id        = var.project_id
  managed_zone_name = module.dns.managed_zone_name
  main_domain       = var.main_domain
  back_records      = module.run-mappings.backend_records
  front_records     = module.run-mappings.front_records
}
