# Resolves the Cloud Logging service agent for this project — the identity
# that must be able to encrypt/decrypt with the CMEK key protecting the log bucket.
data "google_logging_project_cmek_settings" "current" {
  project = data.google_project.current.project_id
}
