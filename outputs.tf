output "bucket_id" {
  value       = google_logging_project_bucket_config.main.id
  description = "ID of the log bucket"
}

output "bucket_name" {
  value       = google_logging_project_bucket_config.main.name
  description = "Full resource name of the log bucket"
}

output "sink_ids" {
  value       = { for k, v in google_logging_project_sink.main : k => v.id }
  description = "Map of sink name to sink ID"
}

output "sink_writer_identities" {
  value       = { for k, v in google_logging_project_sink.main : k => v.writer_identity }
  description = "Map of sink name to the unique writer identity that needs write access on the destination"
}

output "exclusion_ids" {
  value       = { for k, v in google_logging_project_exclusion.main : k => v.id }
  description = "Map of project-level exclusion name to exclusion ID"
}
