terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
