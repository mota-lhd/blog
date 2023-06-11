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
  record_types = ["A", "AAAA"]

  records_by_subdomain = distinct(flatten([
    for index, mapping in google_cloud_run_domain_mapping.mappings : {
      subdomain = index
      data      = { for record in mapping.status[0].resource_records : record.type => record.rrdata... }
    }
  ]))

  tmp_data = distinct(flatten([
    for mapping in local.records_by_subdomain : [
      for record_type in local.record_types : {
        type      = record_type
        subdomain = mapping.subdomain
        data      = mapping.data[record_type]
      }
    ]
  ]))

  records = {
    for mapping in local.tmp_data : "${mapping.subdomain}-${mapping.type}" => mapping
  }
}

resource "google_dns_record_set" "records" {
  for_each = local.records

  project = var.project_id
  name    = "${each.value.subdomain}.${var.main_domain}."
  type    = each.value.type
  ttl     = 300

  managed_zone = google_dns_managed_zone.zone.name

  rrdatas = each.value.data
}
