locals {
  backend_secret_id = "captcha-server-key"
}

resource "google_service_account" "backend_sa" {
  project      = var.project_id
  account_id   = "backend-service-account"
  display_name = "A service account used for backend"
}

module "backend_secret" {
  source = "./modules/secret"

  project_id     = var.project_id
  secret_id      = local.backend_secret_id
  accessor_email = google_service_account.backend_sa.email
}

module "backend" {
  source = "./modules/cloud-run"

  service_name = "backend"
  project_name = var.project_id
  location     = var.location
  runner_sa    = google_service_account.backend_sa.email
  image_name   = "${var.location}-docker.pkg.dev/${var.project_id}/docker/back:latest"
  tcp_port     = 80
  options = {
    env = {
      "SERVICE_NAME"    = "Personal Blog API"
      "CAPTCHA_API_URL" = "https://challenges.cloudflare.com/turnstile/v0/siteverify"
      "PROJECT_ID"      = "${var.project_id}"
    }
    env_from = {
      "CAPTCHA_SERVER_KEY" = {
        key  = "latest"
        name = "${local.backend_secret_id}"
      }
    }
  }
}
