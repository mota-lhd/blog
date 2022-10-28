resource "google_service_account" "umami_sa" {
  project      = var.project_id
  account_id   = "umami-service-account"
  display_name = "A service account used for running umami."
}

resource "google_cloud_run_service" "umami" {
  name     = "umami"
  location = var.location
  project  = var.project_id
  template {
    spec {
      timeout_seconds = 60 * 60

      containers {
        image = "docker.umami.is/umami-software/umami:postgresql-latest"
        resources {
          requests = {
            cpu    = "1000m" # 1 vCPU
            memory = "512Mi"
          }
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        ports {
          name           = "http1"
          protocol       = "TCP"
          container_port = "3000"
        }
        env {
          name = "DATABASE_URL"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "umami-db-url"
            }
          }
        }
        env {
          name = "HASH_SALT"
          value_from {
            secret_key_ref {
              key  = "latest"
              name = "umami-hash-salt"
            }
          }
        }
      }
      service_account_name = google_service_account.umami_sa.email
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

resource "google_cloud_run_service_iam_policy" "noauth_umami" {
  location = var.location
  project  = var.project_id
  service  = google_cloud_run_service.umami.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
