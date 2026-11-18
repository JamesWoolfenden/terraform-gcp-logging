resource "google_kms_crypto_key" "logging" {
  name                       = "logging-key"
  key_ring                   = google_kms_key_ring.logging.id
  rotation_period            = "7776000s" # 90 days
  destroy_scheduled_duration = "2592000s" # 30 days

  lifecycle {
    prevent_destroy = true
  }
}
