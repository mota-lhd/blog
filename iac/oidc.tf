resource "google_iam_workload_identity_pool" "oidc_pool" {
  workload_identity_pool_id = "oidc-pool"
  display_name              = "OIDC pool for CI/CD jobs"
  description               = "Workload identity pool for jobs run from CI/CD pipelines."
  disabled                  = false
  project                   = var.project_id
}

resource "google_iam_workload_identity_pool_provider" "ci_cd_provider_jwt" {
  workload_identity_pool_provider_id = "ci-cd-jwt"
  workload_identity_pool_id          = google_iam_workload_identity_pool.oidc_pool.workload_identity_pool_id
  description                        = "OIDC identity pool provider."
  disabled                           = false
  project                            = var.project_id

  attribute_mapping = {
    "google.subject"             = "assertion.sub", # Required
    "attribute.repository_owner" = "assertion.aud",
    "attribute.repository"       = "assertion.repository"
  }

  attribute_condition = "attribute.repository=='${var.repo_name}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
    allowed_audiences = [
      var.github_org_url
    ]
  }
}

resource "google_service_account_iam_member" "ci_cd_runner_oidc_member" {
  service_account_id = google_service_account.ci_cd.name
  role               = "roles/iam.workloadIdentityUser"

  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.oidc_pool.name}/attribute.repository/${var.repo_name}"
}
