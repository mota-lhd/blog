resource "google_service_account" "frontend_sa" {
  project      = var.project_id
  account_id   = "frontend-service-account"
  display_name = "A service account used for frontend cloud run."
}

module "front" {
  source = "./modules/cloud-run"

  service_name = "elmouatassim"
  project_name = var.project_id
  location     = var.location
  runner_sa    = google_service_account.frontend_sa.email
  image_name   = "${var.location}-docker.pkg.dev/${var.project_id}/docker/front:latest"
  tcp_port     = 80
}
