resource "google_secret_manager_secret" "secret" {
  # Drata: Configure [google_secret_manager_secret.labels] to ensure that organization-wide label conventions are followed.
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
