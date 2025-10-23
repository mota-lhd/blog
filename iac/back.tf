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
