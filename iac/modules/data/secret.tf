resource "google_secret_manager_secret" "captcha_server_key" {
  project   = var.project_id
  secret_id = "captcha-server-key"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "secret_member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.captcha_server_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_sa.email}"
}
