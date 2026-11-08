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

locals {
  # Flatten role -> members into one entry per grant, keyed by "role member" so
  # adding or removing one member never re-creates the others.
  iam_members = {
    for pair in flatten([
      for role, members in var.iam_members : [
        for member in distinct(members) : { role = role, member = member }
      ]
    ]) : "${pair.role} ${pair.member}" => pair
  }
}

# Additive grants: each resource adds one member to one role and leaves every
# other entry on the dataset alone, including grants made outside Terraform.
# The dataset resource above still declares no `access` block, which would be
# authoritative and fight with these.
resource "google_bigquery_dataset_iam_member" "this" {
  for_each = local.iam_members

  project    = google_bigquery_dataset.this.project
  dataset_id = google_bigquery_dataset.this.dataset_id
  role       = each.value.role
  member     = each.value.member
}
