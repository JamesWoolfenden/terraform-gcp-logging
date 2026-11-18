resource "google_logging_project_bucket_config" "main" {
  project          = data.google_project.current.project_id
  location         = var.location
  bucket_id        = var.bucket_id
  description      = var.description
  retention_days   = var.retention_days
  locked           = var.locked
  enable_analytics = var.enable_analytics

  cmek_settings {
    kms_key_name = var.kms_key_name
  }

  depends_on = [google_kms_crypto_key_iam_member.logging_service_agent]

  lifecycle {
    precondition {
      condition     = strcontains(var.kms_key_name, "/locations/${var.location}/")
      error_message = "var.kms_key_name must be a key in the same location as the log bucket (${var.location}); Cloud Logging rejects a CMEK key from another location"
    }
  }
}
