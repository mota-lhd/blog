terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.69.0"
    }
  }

  cloud {
    organization = "mota-lhd"

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
