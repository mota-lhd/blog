resource "google_service_account" "frontend_sa" {
  project      = var.project_id
  account_id   = "frontend-service-account"
  display_name = "A service account used for frontend cloud run."
}

resource "google_cloud_run_service" "elmouatassim" {
  name     = "elmouatassim"
  location = var.location
  project  = var.project_id
  template {
    spec {
      timeout_seconds = 60 * 60

      containers {
        image = "${var.location}-docker.pkg.dev/${var.project_id}/docker/front:latest"
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
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].ports[0].protocol,
      metadata[0].annotations
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

resource "google_cloud_run_service_iam_policy" "noauth_frontend" {
  location = var.location
  project  = var.project_id
  service  = google_cloud_run_service.elmouatassim.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
