output "front_records" {
  value = google_cloud_run_domain_mapping.elmouatassim.status[0].resource_records
}

output "backend_records" {
  value = google_cloud_run_domain_mapping.backend.status[0].resource_records
}

output "umami_records" {
  value = google_cloud_run_domain_mapping.umami.status[0].resource_records
}
