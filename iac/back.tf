module "backend" {
  source = "./modules/cloud-run"

  service_name = "backend"
  project_name = var.project_id
  location     = var.location
  runner_sa    = module.backend-data.backend_sa_email
  image_name   = "${var.location}-docker.pkg.dev/${var.project_id}/docker/back:latest"
  tcp_port     = 80
  options = {
    env = {
      "SERVICE_NAME"    = "Personal Blog API"
      "CAPTCHA_API_URL" = "https://challenges.cloudflare.com/turnstile/v0/siteverify"
      "PROJECT_ID"      = "personal-blog-365822"
    }
    env_from = {
      "CAPTCHA_SERVER_KEY" = {
        key  = "latest"
        name = "captcha-server-key"
      }
    }
  }
}
