resource "google_cloud_run_v2_service_iam_member" "invoker" {
  project  = var.project_name
  location = var.location
  name     = google_cloud_run_v2_service.service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
