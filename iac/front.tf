resource "google_service_account" "frontend_sa" {
  project      = var.project_id
  account_id   = "frontend-service-account"
  display_name = "A service account used for frontend cloud run."
}
