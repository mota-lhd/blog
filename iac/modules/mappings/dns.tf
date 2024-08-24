resource "cloudflare_zone" "main" {
  account_id = var.cf_account_id
  zone       = var.main_domain

  plan       = "free"
  type       = "full"
  paused     = false
}

resource "cloudflare_zone_dnssec" "main" {
  zone_id = cloudflare_zone.main.id
}
