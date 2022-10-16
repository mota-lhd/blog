resource "google_dns_managed_zone" "zone" {
  name     = "default-zone"
  dns_name = "${var.main_domain}."
  project  = var.project_id

  dnssec_config {
    state = "on"
  }
  lifecycle {
    prevent_destroy = true
  }
}

# https://www.google.com/webmasters/verification/home
resource "google_dns_record_set" "backend_verif" {
  project = var.project_id
  name    = "backend.${var.main_domain}."
  type    = "TXT"
  ttl     = 300

  managed_zone = google_dns_managed_zone.zone.name

  rrdatas = ["google-site-verification=TlJejL41u3Cu1Ea3ymLZp2QU8IaaPURi6xkr05SM6RU"]
}

# https://www.google.com/webmasters/verification/home
resource "google_dns_record_set" "elmouatassim_verif" {
  project = var.project_id
  name    = "elmouatassim.${var.main_domain}."
  type    = "TXT"
  ttl     = 300

  managed_zone = google_dns_managed_zone.zone.name

  rrdatas = ["google-site-verification=IiMvco0FcO1xwnBej8eD3kVzFYLAZeswBUfJaK293LY"]
}

resource "google_dns_record_set" "elmouatassim_mappings" {
  for_each = {
    for record in google_cloud_run_domain_mapping.elmouatassim.status[0].resource_records:
    record.type => record.rrdata...
  }
  project = var.project_id
  name    = "elmouatassim.${var.main_domain}."
  type    = each.key
  ttl     = 300

  managed_zone = google_dns_managed_zone.zone.name

  rrdatas = each.value
  depends_on = [
    google_cloud_run_domain_mapping.elmouatassim
  ]
}

resource "google_dns_record_set" "backend_mappings" {
  for_each = {
    for record in google_cloud_run_domain_mapping.backend.status[0].resource_records:
    record.type => record.rrdata...
  }
  project = var.project_id
  name    = "backend.${var.main_domain}."
  type    = each.key
  ttl     = 300

  managed_zone = google_dns_managed_zone.zone.name

  rrdatas = each.value
  depends_on = [
    google_cloud_run_domain_mapping.backend
  ]
}
