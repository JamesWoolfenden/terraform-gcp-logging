resource "google_bigquery_dataset" "logs" {
  dataset_id                  = "audit_logs"
  location                    = local.region
  description                 = "Audit log export from Cloud Logging"
  delete_contents_on_destroy  = false
  default_table_expiration_ms = 34560000000 # 400 days, matches the log bucket retention

  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key.logging.id
  }

  depends_on = [google_kms_crypto_key_iam_member.bigquery_service_agent]
}
