resource "google_cloud_run_service_iam_member" "invoker" {
  project  = var.project_name
  location = var.location
  service  = google_cloud_run_service.service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
