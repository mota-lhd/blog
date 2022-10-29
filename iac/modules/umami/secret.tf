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
