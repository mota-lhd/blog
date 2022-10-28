variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "main_domain" {
  type        = string
  description = "Domain name of the blog"
}

variable "managed_zone_name" {
  type        = string
  description = "Managed zone name"
}

variable "back_records" {
  type        = list(any)
  description = "Mappings A and AAAA records for backend"
}

variable "front_records" {
  type        = list(any)
  description = "Mappings A and AAAA records for frontend"
}

variable "umami_records" {
  type        = list(any)
  description = "Mappings A and AAAA records for umami"
}
