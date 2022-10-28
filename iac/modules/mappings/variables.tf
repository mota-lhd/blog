variable "project_id" {
  type        = string
  description = "Project ID"
  default     = "personal-blog-365822"
}

variable "location" {
  type        = string
  description = "Location of resources"
  default     = "europe-west1"
}

variable "main_domain" {
  type        = string
  description = "Domain name of the blog"
  default     = "louhaidia.info"
}

variable "front_cloud_run_name" {
  type        = string
  description = "Name of frontend cloud-run"
}

variable "backend_cloud_run_name" {
  type        = string
  description = "Name of backend cloud-run"
}

variable "umami_cloud_run_name" {
  type        = string
  description = "Name of umami cloud-run"
}

variable "managed_zone_name" {
  type        = string
  description = "Managed zone name"
}
