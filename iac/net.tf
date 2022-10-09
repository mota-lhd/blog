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

resource "google_dns_record_set" "backend" {
  project = var.project_id
  name    = "backend.${var.main_domain}."
  type    = "A"
  ttl     = 300

  managed_zone = google_dns_managed_zone.zone.name

  rrdatas = [module.lb-http.external_ip]
}

resource "google_dns_record_set" "elmouatassim" {
  project = var.project_id
  name    = "elmouatassim.${var.main_domain}."
  type    = "A"
  ttl     = 300

  managed_zone = google_dns_managed_zone.zone.name

  rrdatas = [module.lb-http.external_ip]
}

resource "google_compute_region_network_endpoint_group" "run_neg" {
  name        = "http-neg"
  description = "Serverless network endpoint group"

  network_endpoint_type = "SERVERLESS"
  region                = var.location
  project               = var.project_id

  cloud_run {
    url_mask = "<service>.${var.main_domain}"
  }
  lifecycle {
    prevent_destroy = true
  }
}

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 6.3"
  name    = "http-lb"
  project = var.project_id

  ssl                             = true
  managed_ssl_certificate_domains = [
    "backend.${var.main_domain}",
    "elmouatassim.${var.main_domain}"
  ]
  https_redirect                  = true
  labels                          = {}

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.run_neg.id
        }
      ]
      enable_cdn              = false
      security_policy         = null
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
      log_config = {
        enable      = false
        sample_rate = null
      }
    }
  }
}
