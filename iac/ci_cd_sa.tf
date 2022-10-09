resource "google_service_account" "ci_cd" {
  project      = var.project_id
  account_id   = "ci-cd-service-account"
  display_name = "A service account used for CI/CD ops."
}

resource "google_service_account_iam_member" "ci_cd_impersonate_main" {
  service_account_id = google_service_account.main.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.ci_cd.email}"
}
