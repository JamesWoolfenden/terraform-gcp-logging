resource "google_logging_project_exclusion" "main" {
  for_each = var.exclusions

  name        = each.key
  filter      = each.value.filter
  description = each.value.description
  disabled    = each.value.disabled
}
