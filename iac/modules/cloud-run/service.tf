resource "google_cloud_run_service" "service" {
  name     = var.service_name
  location = var.location
  project  = var.project_name

  template {
    spec {
      # https://cloud.google.com/run/docs/configuring/request-timeout
      timeout_seconds = 15 * 60

      container_concurrency = 3

      containers {
        image = var.image_name
        ports {
          name           = "http1"
          protocol       = "TCP"
          container_port = var.tcp_port
        }
        dynamic "env" {
          for_each = (try(var.options.env, null) == null ? {} : var.options.env)
          content {
            name  = env.key
            value = env.value
          }
        }
        dynamic "env" {
          for_each = (try(var.options.env_from, null) == null ? {} : var.options.env_from)
          content {
            name = env.key
            value_from {
              secret_key_ref {
                name = env.value.name
                key  = env.value.key
              }
            }
          }
        }
        resources {
          limits = {
            # Memory usage limit (per container)
            # https://cloud.google.com/run/docs/configuring/memory-limits
            memory = "4Gi"
            # CPU usage limit
            # https://cloud.google.com/run/docs/configuring/cpu
            cpu = "1000m" # 1 vCPU
          }
        }
      }
      service_account_name = var.runner_sa
    }
    metadata {
      annotations = {
        # Max instances
        # https://cloud.google.com/run/docs/configuring/max-instances
        "autoscaling.knative.dev/maxScale" = 10
      }
    }
  }
  metadata {
    annotations = {
      # For valid annotation values and descriptions, see
      # https://cloud.google.com/sdk/gcloud/reference/run/deploy#--ingress
      "run.googleapis.com/ingress" = "all"
    }
  }
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].ports[0].protocol,
      template[0].metadata[0],
      metadata[0].annotations,
      traffic
    ]
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}
