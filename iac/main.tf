terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.39.0"
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

  for_each = toset([
    "artifactregistry.googleapis.com",
    "storage.googleapis.com",
    "compute.googleapis.com",
    "run.googleapis.com",
    "container.googleapis.com",
    "secretmanager.googleapis.com",
    "dns.googleapis.com"
  ])

  service                    = each.key
  disable_dependent_services = true
}
