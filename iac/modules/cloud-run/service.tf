resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.location
  project  = var.project_name

  template {
    service_account = var.runner_sa

    scaling {
      max_instance_count = 1
      min_instance_count = 0
    }
    containers {
      image = var.image_name
      ports {
        name           = "http1"
        container_port = var.tcp_port
      }
      startup_probe {
        initial_delay_seconds = 5
        timeout_seconds       = 5
        period_seconds        = 10
        failure_threshold     = 5
        tcp_socket {
          port = var.tcp_port
        }
      }
      liveness_probe {
        http_get {
          path = "/"
        }
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
          value_source {
            secret_key_ref {
              secret  = env.value.name
              version = env.value.key
            }
          }
        }
      }
      resources {
        limits = {
          # Memory usage limit (per container)
          # https://cloud.google.com/run/docs/configuring/memory-limits
          memory = "512Mi"
          # CPU usage limit
          # https://cloud.google.com/run/docs/configuring/cpu
          cpu = "1000m" # 1 vCPU
        }
      }
    }
  }

  ingress = "INGRESS_TRAFFIC_ALL"

  lifecycle {
    ignore_changes = [
      traffic
    ]
  }
  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}
