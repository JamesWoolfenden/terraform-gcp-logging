resource "google_kms_key_ring" "logging" {
  name     = "logging-keyring"
  location = local.region
}
