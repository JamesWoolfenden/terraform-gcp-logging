# holden:ignore:HLD_GCP_003 — this bucket is itself a log archive; access logging it would need a further log bucket, just enough to drive the module
# holden:ignore:HLD_GCP_105 — demo config: locking a GCS retention policy is irreversible and would block teardown of the example for 30 days; set is_locked = true in real use
resource "google_storage_bucket" "logs" {
  name                        = "${data.google_project.current.project_id}-log-archive"
  location                    = local.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  soft_delete_policy {
    retention_duration_seconds = 604800 # 7 days
  }

  lifecycle_rule {
    condition {
      age = 400
    }
    action {
      type = "Delete"
    }
  }

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.logging.id
  }

  retention_policy {
    retention_period = 2592000 # 30 days
    # is_locked = true # irreversible: objects can't be deleted until the period ends. Left unlocked so the example can be torn down.
  }

  depends_on = [google_kms_crypto_key_iam_member.storage_service_agent]
}
