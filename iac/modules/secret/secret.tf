resource "google_secret_manager_secret" "secret" {
  # Drata: Configure [google_secret_manager_secret.rotation.rotation_period] to minimize the risk of secret exposure by ensuring that sensitive values are periodically rotated
  project   = var.project_id
  secret_id = var.secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "member" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.accessor_email}"
}
