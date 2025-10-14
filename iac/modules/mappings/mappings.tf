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
resource "cloudflare_record" "verif" {
  for_each = var.mappings

  zone_id = cloudflare_zone.main.id
  name    = "${each.key}.${var.main_domain}"
  content = each.value.site_verification_txt
  type    = "TXT"
  ttl     = 300
}

locals {
  record_types = ["A", "AAAA"]

  records_by_subdomain = distinct(flatten([
    for subdomain_key, subdomain_val in var.mappings : {
      subdomain = subdomain_key
      data      = { for record in google_cloud_run_domain_mapping.mappings[subdomain_key].status[0].resource_records : record.type => record.rrdata... }
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

resource "cloudflare_record" "records" {
  for_each = local.records

  zone_id = cloudflare_zone.main.id
  name    = "${each.value.subdomain}.${var.main_domain}"
  content = each.value.data[0]
  type    = each.value.type
  ttl     = 1
  proxied = false
}
