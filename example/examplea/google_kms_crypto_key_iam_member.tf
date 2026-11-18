# CMEK grants for the destinations the example creates.
resource "google_kms_crypto_key_iam_member" "storage_service_agent" {
  crypto_key_id = google_kms_crypto_key.logging.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_storage_project_service_account.current.email_address}"
}

resource "google_kms_crypto_key_iam_member" "pubsub_service_agent" {
  crypto_key_id = google_kms_crypto_key.logging.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "bigquery_service_agent" {
  crypto_key_id = google_kms_crypto_key.logging.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_bigquery_default_service_account.current.email}"
}
