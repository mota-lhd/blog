variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "location" {
  type        = string
  description = "Location of resources"
}

variable "repo_name" {
  type        = string
  description = "Repository name used to execute workflows"
}

variable "github_org_url" {
  type        = string
  description = "Github organisation URL to authorise as an audience"
}

variable "main_sa_roles" {
  type = list(any)
}

variable "main_custom_role_perms" {
  type = list(any)
}

variable "main_impersonate_account" {
  type      = string
  sensitive = true
}
