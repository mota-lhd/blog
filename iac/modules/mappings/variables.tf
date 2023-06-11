variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "location" {
  type        = string
  description = "Location of resources"
  default     = "europe-west1"
}

variable "mappings" {
  type = map(object({
    cloud_run_name        = string,
    site_verification_txt = string
  }))
  description = "Map that maps subdomain with a verification text"
  default     = {}
}

variable "main_domain" {
  type        = string
  description = "Domain name of the blog"
}
