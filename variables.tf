variable "project_id" {
  description = "ID of the project in which to create the dataset."
  type        = string
}

variable "dataset_id" {
  description = "Unique dataset id within the project. Letters, numbers and underscores only (BigQuery rejects hyphens and dots)."
  type        = string

  validation {
    # Note: the unbounded quantifier is deliberate. A bounded one ({1,1024})
    # makes `terraform validate` fail against the unknown value it substitutes
    # when no variables are supplied, which would break plain
    # `terraform validate` for consumers and in CI. The length bound is
    # expressed separately.
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.dataset_id)) && length(var.dataset_id) <= 1024
    error_message = "dataset_id must be 1-1024 characters of letters, numbers or underscores only. BigQuery does not accept hyphens, dots or spaces."
  }
}

variable "friendly_name" {
  description = "Human-readable name for the dataset."
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the dataset."
  type        = string
  default     = "Managed by Terraform"
}

variable "location" {
  description = "Geographic location of the dataset, e.g. US or us-central1."
  type        = string
  default     = "US"
}

variable "default_table_expiration_ms" {
  description = <<-EOT
    Default lifetime of newly created tables, in MILLISECONDS. Null (the default)
    disables automatic expiration. Mind the unit: one hour is 3600000, one day is
    86400000 and 30 days is 2592000000. Passing a value in seconds by mistake
    expires live tables far sooner than intended.
  EOT
  type        = number
  default     = null

  validation {
    condition     = var.default_table_expiration_ms == null || try(var.default_table_expiration_ms >= 3600000, false)
    error_message = "default_table_expiration_ms is in MILLISECONDS and BigQuery enforces a minimum of 3600000 (one hour). A value such as 3600 would be seconds, not milliseconds."
  }
}

variable "delete_contents_on_destroy" {
  description = <<-EOT
    Whether `terraform destroy` may delete a dataset that still contains tables.
    Left false (the default), destroying a non-empty dataset fails instead of
    silently dropping every table in it. Only set this to true for datasets whose
    contents are genuinely disposable.
  EOT
  type        = bool
  default     = false
}

variable "kms_key_name" {
  description = <<-EOT
    Full resource id of a Cloud KMS key used to encrypt this dataset's tables
    (CMEK), e.g.
    projects/<project>/locations/<location>/keyRings/<ring>/cryptoKeys/<key>.
    Null (the default) leaves the dataset on Google-managed encryption keys,
    which are still encrypted at rest. The key must live in the same location as
    the dataset.
  EOT
  type        = string
  default     = null

  validation {
    condition = var.kms_key_name == null || can(regex(
      "^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$",
      var.kms_key_name
    ))
    error_message = "kms_key_name must be a full Cloud KMS key id: projects/<project>/locations/<location>/keyRings/<ring>/cryptoKeys/<key>."
  }
}

variable "labels" {
  description = "Labels applied to the dataset."
  type        = map(string)
  default     = {}
}
