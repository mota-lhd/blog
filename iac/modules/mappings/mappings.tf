resource "google_cloud_run_domain_mapping" "mappings" {
  for_each = var.mappings

  name     = "${each.key}.${var.main_domain}"
  location = var.location

  metadata {
    namespace = var.project_id
  }

  spec {
    force_override = true
    route_name     = each.value.cloud_run_name
  }
}

# https://www.google.com/webmasters/verification/home
resource "google_dns_record_set" "verif" {
  for_each = var.mappings

  project = var.project_id
  name    = "${each.key}.${var.main_domain}."
  type    = "TXT"
  ttl     = 300

  managed_zone = google_dns_managed_zone.zone.name

  rrdatas = [each.value.site_verification_txt]
}

locals {
  records = [
    for index, mapping in google_cloud_run_domain_mapping.mappings : {
      subdomain = index
      data      = { for record in mapping.status[0].resource_records : record.type => record.rrdata... }
    }
  ]
}

resource "google_dns_record_set" "a_records" {
  for_each = {
    for mapping in local.records : mapping.subdomain => mapping
  }

  project = var.project_id
  name    = "${each.key}.${var.main_domain}."
  type    = "AAAA"
  ttl     = 300

  managed_zone = google_dns_managed_zone.zone.name

  rrdatas = each.value.data["AAAA"]
}

resource "google_dns_record_set" "aaaa_records" {
  for_each = {
    for mapping in local.records : mapping.subdomain => mapping
  }

  project = var.project_id
  name    = "${each.key}.${var.main_domain}."
  type    = "AAAA"
  ttl     = 300

  managed_zone = google_dns_managed_zone.zone.name

  rrdatas = each.value.data["AAAA"]
}
