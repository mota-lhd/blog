variable "service_name" {
  type        = string
  description = "Service name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "location" {
  type        = string
  description = "Location where to host service"
}

variable "runner_sa" {
  type        = string
  description = "Email of service account who will run the service"
}

variable "image_name" {
  type        = string
  description = "Image path within the artifacts registry"
}

variable "tcp_port" {
  type        = number
  description = "Port opened inside the container"
}

variable "options" {
  type = object({
    probe_url = string
    env       = map(string)
    env_from = map(object({
      key  = string
      name = string
    }))
  })
  description = "Environment variables and secrets to bind to container"
  default = {
    probe_url = "/"
    env = {
      # "env_var_name" = "env_var_val"
    }
    env_from = {
      # "env_var_name" = {
      #  key  = "version_id or latest"
      #  name = "secret-name in secret-manager"
      # }
    }
  }
}
