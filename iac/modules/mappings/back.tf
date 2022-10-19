resource "google_cloud_run_domain_mapping" "backend" {
  name     = "backend.${var.main_domain}"
  location = var.location

  metadata {
    namespace = var.project_id
  }
  spec {
    force_override = true
    route_name     = var.backend_cloud_run_name
  }
}

# https://www.google.com/webmasters/verification/home
resource "google_dns_record_set" "backend_verif" {
  project = var.project_id
  name    = "backend.${var.main_domain}."
  type    = "TXT"
  ttl     = 300

  managed_zone = var.managed_zone_name

  rrdatas = ["google-site-verification=TlJejL41u3Cu1Ea3ymLZp2QU8IaaPURi6xkr05SM6RU"]
}
