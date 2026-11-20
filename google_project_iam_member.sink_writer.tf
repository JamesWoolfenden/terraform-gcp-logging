# Lets each cross-project log bucket sink's unique writer identity write to its destination
# bucket, scoped by condition to that bucket only.
resource "google_project_iam_member" "sink_writer" {
  for_each = local.cross_project_logging_sinks

  project = each.value.project
  role    = "roles/logging.bucketWriter"
  member  = google_logging_project_sink.main[each.key].writer_identity

  condition {
    title       = "sink-${each.key}"
    description = "Write access for sink ${each.key} to its destination log bucket only"
    expression  = "resource.name.endsWith(\"${each.value.bucket}\")"
  }
}
