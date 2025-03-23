# resource "google_firestore_database" "database" {
#   project     = var.project_id
#   name        = "(default)"
#   location_id = var.location

#   type = "DATASTORE_MODE"

#   app_engine_integration_mode = "DISABLED"
#   delete_protection_state     = "DELETE_PROTECTION_ENABLED"
# }

# resource "google_firestore_index" "blog_post_comment" {
#   project    = var.project_id
#   database   = google_firestore_database.database.name
#   collection = "Comment"

#   query_scope = "COLLECTION_RECURSIVE"
#   api_scope   = "DATASTORE_MODE_API"

#   fields {
#     field_path = "visible"
#     order      = "DESCENDING"
#   }

#   fields {
#     field_path = "ts"
#     order      = "DESCENDING"
#   }
# }

resource "google_project_iam_member" "datastore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.backend_sa.email}"
}
