resource "google_service_account" "backend_sa" {
  project      = var.project_id
  account_id   = "backend-service-account"
  display_name = "A service account used for backend cloud run."
}

resource "google_service_account" "frontend_sa" {
  project      = var.project_id
  account_id   = "frontend-service-account"
  display_name = "A service account used for frontend cloud run."
}

resource "google_cloud_run_service" "backend" {
  name     = "backend"
  location = var.location
  project  = var.project_id
  template {
    spec {
      timeout_seconds = 60 * 60

      containers {
        image = "${var.location}-docker.pkg.dev/${var.project_id}/docker-repo/web/back:latest"
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
          name  = "GOOGLE_CAPTCHA_API_URL"
          value = "https://www.google.com/recaptcha/api/siteverify"
        }
        env {
          name = "GOOGLE_CAPTCHA_SERVER_KEY"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "google-captcha-server-key"
            }
          }
        }
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
      }
      service_account_name = google_service_account.backend_sa.email
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
}

resource "google_cloud_run_domain_mapping" "backend" {
  name     = "backend.${var.main_domain}"
  location = google_cloud_run_service.backend.location
  metadata {
    namespace = var.project_id
  }
  spec {
    route_name = google_cloud_run_service.backend.name
  }
}

resource "google_cloud_run_service" "elmouatassim" {
  name     = "elmouatassim"
  location = var.location
  project  = var.project_id
  template {
    spec {
      timeout_seconds = 60 * 60

      containers {
        image = "${var.location}-docker.pkg.dev/${var.project_id}/docker-repo/web/front:latest"
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
      }
      service_account_name = google_service_account.frontend_sa.email
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
}

resource "google_cloud_run_domain_mapping" "elmouatassim" {
  name     = "elmouatassim.${var.main_domain}"
  location = google_cloud_run_service.elmouatassim.location
  metadata {
    namespace = var.project_id
  }
  spec {
    route_name = google_cloud_run_service.elmouatassim.name
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
  location    = var.location
  project     = var.project_id
  service     = google_cloud_run_service.backend.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_service_iam_policy" "noauth_frontend" {
  location    = var.location
  project     = var.project_id
  service     = google_cloud_run_service.elmouatassim.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
