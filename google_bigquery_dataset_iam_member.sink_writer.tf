# Lets each BigQuery sink's unique writer identity write tables in its destination dataset.
resource "google_bigquery_dataset_iam_member" "sink_writer" {
  for_each = local.bigquery_sinks

  project    = split("/", trimprefix(each.value.destination, "bigquery.googleapis.com/"))[1]
  dataset_id = split("/", trimprefix(each.value.destination, "bigquery.googleapis.com/"))[3]
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.main[each.key].writer_identity
}
