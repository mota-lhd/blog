variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "location" {
  type        = string
  description = "Location of resources"
}

variable "main_domain" {
  type        = string
  description = "Main domain name of the blog"
}

variable "main_impersonate_account" {
  type        = string
  sensitive   = true
  description = "Account granted impersonation on main service account of the blog"
}

variable "github_org_url" {
  type        = string
  description = "Github org. used to execute workflows"
}

variable "repo_name" {
  type        = string
  description = "Repository name used to execute workflows"
}

variable "main_sa_roles" {
  type        = list(any)
  description = "Main service account roles"
}

variable "main_custom_role_perms" {
  type        = list(any)
  description = "Permissions associated to the main custom role"
}

variable "gcp_api_to_activate" {
  type        = list(any)
  description = "GCP services that need to be activated in the project"
}

variable "cloudflare_api_token" {
  type        = string
  description = "CloudFlare API token"
}

variable "cloudflare_account_id" {
  type        = string
  description = "CloudFlare account ID"
}
