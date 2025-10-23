resource "google_project_service" "default_services" {
  project = var.project_id

  for_each = toset(var.gcp_api_to_activate)

  service                    = each.key
  disable_dependent_services = true
}
