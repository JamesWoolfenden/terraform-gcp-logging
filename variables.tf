variable "bucket_id" {
  type        = string
  description = "ID of the log bucket to create"

  validation {
    condition     = can(regex("^[A-Za-z0-9_-][A-Za-z0-9_.-]{0,99}$", var.bucket_id)) && !startswith(var.bucket_id, "_")
    error_message = "var.bucket_id must be 1-100 characters of letters, digits, underscores, hyphens or periods, and must not start with an underscore (reserved for _Default/_Required)"
  }
}

variable "location" {
  type        = string
  description = "Location of the log bucket; must be a region (not global) so it can be protected with a regional CMEK key"
  default     = "europe-west2"

  validation {
    condition     = length(trimspace(var.location)) > 0 && var.location != "global"
    error_message = "var.location must be a non-empty region; global log buckets cannot use CMEK"
  }
}

variable "description" {
  type        = string
  description = "Human-readable description of the log bucket"

  validation {
    condition     = length(trimspace(var.description)) > 0
    error_message = "var.description must be a non-empty string"
  }
}

variable "retention_days" {
  type        = number
  description = "Number of days logs are retained in the bucket (minimum 30, maximum 3650)"
  default     = 365

  validation {
    condition     = var.retention_days >= 30 && var.retention_days <= 3650 && floor(var.retention_days) == var.retention_days
    error_message = "var.retention_days must be a whole number between 30 and 3650"
  }
}

variable "kms_key_name" {
  type        = string
  description = "KMS crypto key used to encrypt the log bucket; must be in the same location as var.location"
  sensitive   = true

  validation {
    condition     = length(trimspace(var.kms_key_name)) > 0
    error_message = "var.kms_key_name must be a non-empty string"
  }
}

variable "locked" {
  type        = bool
  description = "Lock the bucket's retention policy; once locked the bucket and its retention cannot be reduced or deleted"
  default     = false

  validation {
    condition     = var.locked != null
    error_message = "var.locked must be true or false"
  }
}

variable "enable_analytics" {
  type        = bool
  description = "Enable Log Analytics on the bucket so logs can be queried with SQL"
  default     = false

  validation {
    condition     = var.enable_analytics != null
    error_message = "var.enable_analytics must be true or false"
  }
}

variable "sinks" {
  type = map(object({
    destination            = optional(string)
    destination_type       = optional(string, "logging")
    filter                 = string
    description            = string
    disabled               = optional(bool, false)
    use_partitioned_tables = optional(bool, true)
    exclusions = optional(list(object({
      name        = string
      filter      = string
      description = optional(string)
      disabled    = optional(bool, false)
    })), [])
  }))
  description = <<-EOT
  Map of sink name to sink definition. destination_type is one of storage, pubsub, bigquery or logging and must
  match destination (storage.googleapis.com/BUCKET, pubsub.googleapis.com/projects/P/topics/T,
  bigquery.googleapis.com/projects/P/datasets/D or logging.googleapis.com/projects/P/locations/L/buckets/B).
  Leave destination unset to route to the log bucket this module creates. Each sink gets a unique writer identity,
  and the module grants it write access on storage/pubsub/bigquery destinations.
  EOT
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.sinks : can(regex("^[A-Za-z0-9_.-]{1,100}$", k))])
    error_message = "var.sinks keys must be 1-100 characters of letters, digits, underscores, hyphens or periods"
  }

  validation {
    condition     = alltrue([for v in values(var.sinks) : contains(["storage", "pubsub", "bigquery", "logging"], v.destination_type)])
    error_message = "var.sinks destination_type must be one of storage, pubsub, bigquery or logging"
  }

  validation {
    condition     = alltrue([for v in values(var.sinks) : length(trimspace(v.filter)) > 0 && length(trimspace(v.description)) > 0])
    error_message = "var.sinks filter and description must be non-empty; an empty filter exports every log entry in the project"
  }

  validation {
    condition = alltrue([for v in values(var.sinks) : (v.destination == null && v.destination_type == "logging") || (
      (v.destination_type == "storage" && can(regex("^storage\\.googleapis\\.com/[a-z0-9][a-z0-9._-]+$", v.destination))) ||
      (v.destination_type == "pubsub" && can(regex("^pubsub\\.googleapis\\.com/projects/[^/]+/topics/[^/]+$", v.destination))) ||
      (v.destination_type == "bigquery" && can(regex("^bigquery\\.googleapis\\.com/projects/[^/]+/datasets/[^/]+$", v.destination))) ||
      (v.destination_type == "logging" && can(regex("^logging\\.googleapis\\.com/projects/[^/]+/locations/[^/]+/buckets/[^/]+$", v.destination)))
    )])
    error_message = "var.sinks destination must match the format for its destination_type; destination may only be omitted when destination_type is logging (routes to this module's bucket)"
  }

  validation {
    condition     = alltrue(flatten([for v in values(var.sinks) : [for e in v.exclusions : length(trimspace(e.name)) > 0 && length(trimspace(e.filter)) > 0]]))
    error_message = "var.sinks exclusions must have a non-empty name and filter"
  }
}

variable "exclusions" {
  type = map(object({
    filter      = string
    description = optional(string)
    disabled    = optional(bool, false)
  }))
  description = "Optional project-level log exclusions (applied to the _Default sink), keyed by exclusion name. Use sparingly: excluded logs are dropped, not stored"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.exclusions : can(regex("^[A-Za-z0-9_.-]{1,100}$", k)) && length(trimspace(v.filter)) > 0])
    error_message = "var.exclusions keys must be 1-100 characters of letters, digits, underscores, hyphens or periods, and each filter must be non-empty"
  }
}
