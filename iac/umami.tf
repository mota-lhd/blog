resource "google_service_account" "umami_sa" {
  project      = var.project_id
  account_id   = "umami-service-account"
  display_name = "A service account used for running umami."
}

resource "google_secret_manager_secret" "umami_db_url" {
  project   = var.project_id
  secret_id = "umami-db-url"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret" "umami_hash_salt" {
  project   = var.project_id
  secret_id = "umami-hash-salt"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "url_member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.umami_db_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.umami_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "hash_member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.umami_hash_salt.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.umami_sa.email}"
}

module "umami" {
  source = "./modules/cloud-run"

  service_name = "umami"
  project_name = var.project_id
  location     = var.location
  runner_sa    = google_service_account.umami_sa.email
  image_name   = "europe-west1-docker.pkg.dev/${var.project_id}/docker/umami:latest"
  tcp_port     = 3000
  options = {
    env_from = {
      "DATABASE_URL" = {
        key  = "latest"
        name = "umami-db-url"
      }
    }
    env_from = {
      "HASH_SALT" = {
        key  = "latest"
        name = "umami-hash-salt"
      }
    }
  }
}
