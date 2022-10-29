resource "google_cloud_run_domain_mapping" "umami" {
  name     = "umami.${var.main_domain}"
  location = var.location

  metadata {
    namespace = var.project_id
  }
  spec {
    force_override = true
    route_name     = var.umami_cloud_run_name
  }
}

# https://www.google.com/webmasters/verification/home
resource "google_dns_record_set" "umami_verif" {
  project = var.project_id
  name    = "umami.${var.main_domain}."
  type    = "TXT"
  ttl     = 300

  managed_zone = var.managed_zone_name

  rrdatas = ["google-site-verification=W4pCsmPQ4hrLaIyHxGteKsUAaU1bf67r3RYzV9re90s"]
}
