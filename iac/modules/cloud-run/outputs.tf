output "urls" {
  value = [for status in google_cloud_run_service.service.status : status.url]
}

output "cloud_run_name" {
  value = google_cloud_run_service.backend.name
}
