resource "google_secret_manager_secret" "secret" {
  project   = var.project_id
  secret_id = var.secret_id

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_iam_member" "member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.accessor_email}"
}
