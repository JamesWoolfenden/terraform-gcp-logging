# Lets each storage sink's unique writer identity create log objects in its destination bucket.
resource "google_storage_bucket_iam_member" "sink_writer" {
  for_each = local.storage_sinks

  bucket = trimprefix(each.value.destination, "storage.googleapis.com/")
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.main[each.key].writer_identity
}
