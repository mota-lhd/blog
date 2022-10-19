resource "google_cloud_run_domain_mapping" "elmouatassim" {
  name     = "elmouatassim.${var.main_domain}"
  location = var.location
  metadata {
    namespace = var.project_id
  }
  spec {
    force_override = true
    route_name     = var.front_cloud_run_name
  }
}

# https://www.google.com/webmasters/verification/home
resource "google_dns_record_set" "elmouatassim_verif" {
  project = var.project_id
  name    = "elmouatassim.${var.main_domain}."
  type    = "TXT"
  ttl     = 300

  managed_zone = var.managed_zone_name

  rrdatas = ["google-site-verification=IiMvco0FcO1xwnBej8eD3kVzFYLAZeswBUfJaK293LY"]
}
