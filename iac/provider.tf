terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
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

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
