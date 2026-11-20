# Cloud KMS IAM grants take up to a few minutes to propagate, and Cloud Logging checks the
# service agent's access to the key when it creates a CMEK bucket; wait before creating it.
resource "time_sleep" "kms_propagation" {
  create_duration = "60s"

  triggers = {
    grant = google_kms_crypto_key_iam_member.logging_service_agent.id
  }
}
