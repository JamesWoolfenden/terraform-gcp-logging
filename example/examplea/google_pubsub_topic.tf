resource "google_pubsub_topic" "logs" {
  name                       = "log-alerts"
  kms_key_name               = google_kms_crypto_key.logging.id
  message_retention_duration = "604800s"

  depends_on = [google_kms_crypto_key_iam_member.pubsub_service_agent]
}
