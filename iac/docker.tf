resource "google_artifact_registry_repository" "docker-repo" {
  project       = var.project_id
  location      = var.location
  repository_id = "docker-repo"
  description   = "Docker images"
  format        = "DOCKER"
}
