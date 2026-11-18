locals {
  # Cloud Logging service agent that encrypts log bucket data with the CMEK key.
  logging_service_agent = "serviceAccount:${data.google_logging_project_cmek_settings.current.service_account_id}"

  # Sinks with no explicit destination route to the log bucket this module creates.
  sinks = {
    for k, v in var.sinks : k => merge(v, {
      destination = coalesce(v.destination, "logging.googleapis.com/${google_logging_project_bucket_config.main.id}")
      # bigquery_options is only valid on BigQuery sinks.
      bigquery_options = v.destination_type == "bigquery" ? [v.use_partitioned_tables] : []
    })
  }

  storage_sinks  = { for k, v in local.sinks : k => v if v.destination_type == "storage" }
  pubsub_sinks   = { for k, v in local.sinks : k => v if v.destination_type == "pubsub" }
  bigquery_sinks = { for k, v in local.sinks : k => v if v.destination_type == "bigquery" }
}
