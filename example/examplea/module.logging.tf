# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "logging" {
  source         = "../../"
  bucket_id      = "central-logs"
  location       = local.region
  description    = "Central CMEK-protected log bucket"
  retention_days = 400
  kms_key_name   = google_kms_crypto_key.logging.id

  sinks = {
    "audit-to-log-bucket" = {
      filter      = "logName:\"cloudaudit.googleapis.com\""
      description = "Route audit logs to the central log bucket"
    }
    "errors-to-storage" = {
      destination      = "storage.googleapis.com/${google_storage_bucket.logs.name}"
      destination_type = "storage"
      filter           = "severity>=ERROR"
      description      = "Archive error logs to Cloud Storage"
      exclusions = [{
        name   = "no-debug-noise"
        filter = "resource.type=\"k8s_container\" AND severity<WARNING"
      }]
    }
    "critical-to-pubsub" = {
      destination      = "pubsub.googleapis.com/${google_pubsub_topic.logs.id}"
      destination_type = "pubsub"
      filter           = "severity>=CRITICAL"
      description      = "Stream critical logs to Pub/Sub for alerting"
    }
    "audit-to-bigquery" = {
      destination      = "bigquery.googleapis.com/projects/${data.google_project.current.project_id}/datasets/${google_bigquery_dataset.logs.dataset_id}"
      destination_type = "bigquery"
      filter           = "logName:\"cloudaudit.googleapis.com%2Factivity\""
      description      = "Export admin activity audit logs to BigQuery"
    }
  }
}
