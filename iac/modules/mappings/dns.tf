resource "cloudflare_zone" "main" {
  account = {
    id = var.cf_account_id
  }

  name   = var.main_domain
  type   = "full"
  paused = false
}

resource "cloudflare_zone_dnssec" "main" {
  zone_id = cloudflare_zone.main.id
}
