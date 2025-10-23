locals {
  umami_secret_1_id = "umami-db-url"
  umami_secret_2_id = "umami-hash-salt"
}

resource "google_service_account" "umami_sa" {
  project      = var.project_id
  account_id   = "umami-service-account"
  display_name = "A service account used for running umami."
}

module "umami_secret_1" {
  source = "./modules/secret"

  project_id     = var.project_id
  secret_id      = local.umami_secret_1_id
  accessor_email = google_service_account.umami_sa.email
}

module "umami_secret_2" {
  source = "./modules/secret"

  project_id     = var.project_id
  secret_id      = local.umami_secret_2_id
  accessor_email = google_service_account.umami_sa.email
}
