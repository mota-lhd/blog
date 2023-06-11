output "urls" {
  value = [for status in google_cloud_run_service.service.status : status.url]
}
