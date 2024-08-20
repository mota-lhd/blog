resource "google_dns_managed_zone" "zone" {
  name     = "default-zone"
  dns_name = "${var.main_domain}."
  project  = var.project_id

  dnssec_config {
    state = "on"
  }
  lifecycle {
    prevent_destroy = false
  }
}
