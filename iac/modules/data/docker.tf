resource "google_artifact_registry_repository" "docker" {
  project       = var.project_id
  location      = var.location
  repository_id = "docker"
  description   = "Docker images"
  format        = "DOCKER"
}
