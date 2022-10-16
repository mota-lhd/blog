resource "google_service_account" "main" {
  project      = var.project_id
  account_id   = "main-service-account"
  display_name = "A service account that rules project"
}

resource "google_project_iam_custom_role" "main_custom" {
  project     = var.project_id
  role_id     = "main_custom_role"
  title       = "Main Custom Role"
  permissions = var.main_custom_role_perms
}

resource "google_project_iam_member" "main_custom" {
  project = var.project_id
  role    = google_project_iam_custom_role.main_custom.name

  member = "serviceAccount:${google_service_account.main.email}"
}

resource "google_project_iam_member" "main_sa_roles" {
  for_each = toset(var.main_sa_roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.main.email}"
}

resource "google_service_account_iam_member" "main_impersonate" {
  service_account_id = google_service_account.main.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${var.main_impersonate_account}"
}
