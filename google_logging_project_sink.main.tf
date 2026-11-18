resource "google_logging_project_sink" "main" {
  for_each = local.sinks

  name                   = each.key
  destination            = each.value.destination
  filter                 = each.value.filter
  description            = each.value.description
  disabled               = each.value.disabled
  unique_writer_identity = true

  dynamic "bigquery_options" {
    for_each = each.value.bigquery_options
    content {
      use_partitioned_tables = bigquery_options.value
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions
    content {
      name        = exclusions.value.name
      filter      = exclusions.value.filter
      description = exclusions.value.description
      disabled    = exclusions.value.disabled
    }
  }
}
