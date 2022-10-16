variable "project_id" {
  type        = string
  description = "Project ID"
  default     = "personal-blog-364911"
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

variable "main_sa_roles" {
  type        = list(string)
  description = "List of roles for main service account"
  default = [
    "roles/viewer",
    "roles/container.admin",
    "roles/compute.admin",
    "roles/storage.admin",
    "roles/secretmanager.admin",
    "roles/run.admin",
    "roles/datastore.owner",
    "roles/artifactregistry.admin",
    "roles/dns.admin"
  ]
}

variable "main_sa_custom_permissions" {
  type = list(string)
  default = [
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete"
  ]
}

variable "main_impersonate_account" {
  type        = string
  description = "Account used to impersonate main service account"
  default     = "user:mota.lhd@gmail.com"
}

variable "github_org_url" {
  type        = string
  description = "Github org. used to execute workflows"
  default     = "https://github.com/mota-lhd"
}

variable "repo_name" {
  type        = string
  description = "Repository name used to execute workflows"
  default     = "mota-lhd/blog"
}

variable "sub_github" {
  type = string
  default = "repo:mota-lhd/blog:ref:refs/heads/main"
}
