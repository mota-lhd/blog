resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.location
  database_type = "CLOUD_DATASTORE_COMPATIBILITY"
}

resource "google_datastore_index" "blog_post_comment" {
  kind     = "Comment"
  ancestor = "ALL_ANCESTORS"
  project = var.project_id

  properties {
    name = "visible"
    direction = "DESCENDING"
  }
  properties {
    name      = "ts"
    direction = "DESCENDING"
  }
}

resource "google_project_iam_member" "datastore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.backend_sa.email}"
}
