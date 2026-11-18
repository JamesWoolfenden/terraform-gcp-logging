# Lets each Pub/Sub sink's unique writer identity publish to its destination topic.
resource "google_pubsub_topic_iam_member" "sink_writer" {
  for_each = local.pubsub_sinks

  topic  = trimprefix(each.value.destination, "pubsub.googleapis.com/")
  role   = "roles/pubsub.publisher"
  member = google_logging_project_sink.main[each.key].writer_identity
}
