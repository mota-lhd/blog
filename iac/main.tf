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
    "backend" = {
      cloud_run_name        = "backend"
      site_verification_txt = "google-site-verification=TlJejL41u3Cu1Ea3ymLZp2QU8IaaPURi6xkr05SM6RU"
    }
    "elmouatassim" = {
      cloud_run_name        = "elmouatassim"
      site_verification_txt = "google-site-verification=IiMvco0FcO1xwnBej8eD3kVzFYLAZeswBUfJaK293LY"
    }
    "umami" = {
      cloud_run_name        = "umami"
      site_verification_txt = "google-site-verification=W4pCsmPQ4hrLaIyHxGteKsUAaU1bf67r3RYzV9re90s"
    }
  }
}
