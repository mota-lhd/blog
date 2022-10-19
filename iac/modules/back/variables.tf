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

variable "backend_sa_email" {
  type        = string
  description = "Datastore user email to authorize"
}
