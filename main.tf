resource "google_bigquery_dataset" "this" {
  project                     = var.project_id
  dataset_id                  = var.dataset_id
  friendly_name               = var.friendly_name
  description                 = var.description
  location                    = var.location
  default_table_expiration_ms = var.default_table_expiration_ms
  delete_contents_on_destroy  = var.delete_contents_on_destroy
  labels                      = var.labels

  # Customer-managed encryption. The block is omitted entirely when
  # var.kms_key_name is null, in which case BigQuery falls back to
  # Google-managed keys (data is still encrypted at rest). The project's
  # BigQuery service account must hold
  # roles/cloudkms.cryptoKeyEncrypterDecrypter on the key before apply.
  dynamic "default_encryption_configuration" {
    for_each = var.kms_key_name == null ? [] : [var.kms_key_name]

    content {
      kms_key_name = default_encryption_configuration.value
    }
  }
}
