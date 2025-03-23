resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "main" {
  private_key_pem = tls_private_key.main.private_key_pem

  subject {
    common_name  = "*.${var.main_domain}"
    organization = "elmouatassim"
  }
}

resource "cloudflare_origin_ca_certificate" "main" {
  csr                = tls_cert_request.main.cert_request_pem
  hostnames          = [var.main_domain, "*.${var.main_domain}"]
  request_type       = "origin-rsa"
  requested_validity = 5475 # 15 years
}
