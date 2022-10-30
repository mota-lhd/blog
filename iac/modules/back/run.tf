resource "google_cloud_run_service" "backend" {
  name     = "backend"
  location = var.location
  project  = var.project_id
  template {
    spec {
      timeout_seconds = 60 * 60

      containers {
        image = "${var.location}-docker.pkg.dev/${var.project_id}/docker/back:latest"
        resources {
          requests = {
            cpu    = "1000m" # 1 vCPU
            memory = "128Mi"
          }
          limits = {
            cpu    = "1000m"
            memory = "256Mi"
          }
        }
        ports {
          name           = "http1"
          protocol       = "TCP"
          container_port = "80"
        }
        env {
          name  = "SERVICE_NAME"
          value = "Personal Blog API"
        }
        env {
          name  = "CAPTCHA_API_URL"
          value = "https://challenges.cloudflare.com/turnstile/v0/siteverify"
        }
        env {
          name = "CAPTCHA_SERVER_KEY"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "captcha-server-key"
            }
          }
        }
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
      }
      service_account_name = var.backend_sa_email
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = 1
      }
    }
  }
  metadata {
    annotations = {
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].ports[0].protocol,
      metadata[0].annotations,
      template[0].metadata[0]
    ]
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth_backend" {
  location = var.location
  project  = var.project_id
  service  = google_cloud_run_service.backend.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
