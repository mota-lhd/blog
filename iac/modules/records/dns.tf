resource "google_dns_record_set" "elmouatassim_mappings" {
  for_each = {
    for record in var.front_records :
    record.type => record.rrdata...
  }
  project = var.project_id
  name    = "elmouatassim.${var.main_domain}."
  type    = each.key
  ttl     = 300

  managed_zone = var.managed_zone_name

  rrdatas = each.value
}

resource "google_dns_record_set" "backend_mappings" {
  for_each = {
    for record in var.back_records :
    record.type => record.rrdata...
  }
  project = var.project_id
  name    = "backend.${var.main_domain}."
  type    = each.key
  ttl     = 300

  managed_zone = var.managed_zone_name

  rrdatas = each.value
}

resource "google_dns_record_set" "umami_mappings" {
  for_each = {
    for record in var.umami_records :
    record.type => record.rrdata...
  }
  project = var.project_id
  name    = "umami.${var.main_domain}."
  type    = each.key
  ttl     = 300

  managed_zone = var.managed_zone_name

  rrdatas = each.value
}
