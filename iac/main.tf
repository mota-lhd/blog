resource "google_project_service" "default_services" {
  project = var.project_id

  for_each = toset(var.gcp_api_to_activate)

  service                    = each.key
  disable_dependent_services = true
}

module "run-mappings" {
  source = "./modules/mappings"

  project_id           = var.project_id
  location             = var.location
  main_domain          = var.main_domain
  cloudflare_api_token = var.cloudflare_api_token
  cf_account_id        = var.cloudflare_account_id

  mappings = {
  }
}
