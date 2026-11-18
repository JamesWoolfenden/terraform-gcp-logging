# terraform-gcp-logging

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-logging/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-logging/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-logging.svg)](https://github.com/JamesWoolfenden/terraform-gcp-logging/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-logging.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-logging/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for Cloud Logging. Creates a CMEK-protected, regional log bucket (retention of at least 30 days, optional retention lock and Log Analytics) with the KMS grant the Cloud Logging service agent needs, a map of log sinks (each with a unique writer identity and optional exclusions) routing to that bucket, Cloud Storage, Pub/Sub, BigQuery or another log bucket, the least-privilege IAM grant for each sink's writer identity on its storage/Pub/Sub/BigQuery destination, and optional project-level exclusions.

## Usage

Add **module.logging.tf** to your code:-

```terraform
module "logging" {
  source         = "jameswoolfenden/logging/gcp"
  bucket_id      = "central-logs"
  location       = "europe-west2"
  description    = "Central CMEK-protected log bucket"
  retention_days = 400
  kms_key_name   = google_kms_crypto_key.logging.id

  sinks = {
    "errors-to-storage" = {
      destination      = "storage.googleapis.com/${google_storage_bucket.logs.name}"
      destination_type = "storage"
      filter           = "severity>=ERROR"
      description      = "Archive error logs to Cloud Storage"
    }
  }
}
```

See [example/examplea](example/examplea) for a complete working example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_bigquery_dataset_iam_member.sink_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_kms_crypto_key_iam_member.logging_service_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_logging_project_bucket_config.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_bucket_config) | resource |
| [google_logging_project_cmek_settings.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/logging_project_cmek_settings) | data source |
| [google_logging_project_exclusion.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_exclusion) | resource |
| [google_logging_project_sink.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_project.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_pubsub_topic_iam_member.sink_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_storage_bucket_iam_member.sink_writer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bucket_id"></a> [bucket\_id](#input\_bucket\_id) | ID of the log bucket to create | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Human-readable description of the log bucket | `string` | n/a | yes |
| <a name="input_enable_analytics"></a> [enable\_analytics](#input\_enable\_analytics) | Enable Log Analytics on the bucket so logs can be queried with SQL | `bool` | `false` | no |
| <a name="input_exclusions"></a> [exclusions](#input\_exclusions) | Optional project-level log exclusions (applied to the \_Default sink), keyed by exclusion name. Use sparingly: excluded logs are dropped, not stored | <pre>map(object({filter = string description = optional(string) disabled = optional(bool, false)}))</pre> | `{}` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | KMS crypto key used to encrypt the log bucket; must be in the same location as var.location | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location of the log bucket; must be a region (not global) so it can be protected with a regional CMEK key | `string` | `"europe-west2"` | no |
| <a name="input_locked"></a> [locked](#input\_locked) | Lock the bucket's retention policy; once locked the bucket and its retention cannot be reduced or deleted | `bool` | `false` | no |
| <a name="input_retention_days"></a> [retention\_days](#input\_retention\_days) | Number of days logs are retained in the bucket (minimum 30, maximum 3650) | `number` | `365` | no |
| <a name="input_sinks"></a> [sinks](#input\_sinks) | Map of sink name to sink definition. destination\_type is one of storage, pubsub, bigquery or logging and must match destination (storage.googleapis.com/BUCKET, pubsub.googleapis.com/projects/P/topics/T, bigquery.googleapis.com/projects/P/datasets/D or logging.googleapis.com/projects/P/locations/L/buckets/B). Leave destination unset to route to the log bucket this module creates. Each sink gets a unique writer identity, and the module grants it write access on storage/pubsub/bigquery destinations. | <pre>map(object({destination = optional(string) destination_type = optional(string, "logging") filter = string description = string disabled = optional(bool, false) use_partitioned_tables = optional(bool, true) exclusions = optional(list(object({name = string filter = string description = optional(string) disabled = optional(bool, false)})), [])}))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | ID of the log bucket |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Full resource name of the log bucket |
| <a name="output_exclusion_ids"></a> [exclusion\_ids](#output\_exclusion\_ids) | Map of project-level exclusion name to exclusion ID |
| <a name="output_sink_ids"></a> [sink\_ids](#output\_sink\_ids) | Map of sink name to sink ID |
| <a name="output_sink_writer_identities"></a> [sink\_writer\_identities](#output\_sink\_writer\_identities) | Map of sink name to the unique writer identity that needs write access on the destination |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Role and Permissions

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "bigquery.datasets.getIamPolicy",
    "bigquery.datasets.setIamPolicy",
    "bigquery.datasets.update",
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.cryptoKeys.setIamPolicy",
    "logging.buckets.create",
    "logging.buckets.delete",
    "logging.buckets.get",
    "logging.buckets.update",
    "logging.exclusions.create",
    "logging.exclusions.delete",
    "logging.exclusions.get",
    "logging.exclusions.update",
    "logging.settings.get",
    "logging.sinks.create",
    "logging.sinks.delete",
    "logging.sinks.get",
    "logging.sinks.update",
    "pubsub.topics.getIamPolicy",
    "pubsub.topics.setIamPolicy",
    "resourcemanager.projects.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.setIamPolicy"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "bigquery.datasets.getIamPolicy",
    "cloudkms.cryptoKeys.getIamPolicy",
    "logging.buckets.get",
    "logging.exclusions.get",
    "logging.settings.get",
    "logging.sinks.get",
    "pubsub.topics.getIamPolicy",
    "resourcemanager.projects.get",
    "storage.buckets.getIamPolicy"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-gcp-logging/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-gcp-logging/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
