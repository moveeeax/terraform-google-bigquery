# Unit tests for the dataset module.
#
# These run fully offline against a mocked google provider, so no credentials,
# no project and no network access are required: `terraform test`.
#
# NOTE: `mock_provider` requires Terraform >= 1.7 / OpenTofu >= 1.7. That is a
# requirement of the test suite only -- the module itself still supports the
# >= 1.5 declared in versions.tf, so do not raise required_version for this.

mock_provider "google" {}

variables {
  project_id = "test-project"
  dataset_id = "analytics"
}

run "defaults_are_safe" {
  assert {
    condition     = google_bigquery_dataset.this.delete_contents_on_destroy == false
    error_message = "delete_contents_on_destroy must default to false: a true default lets terraform destroy silently drop every table in the dataset."
  }

  assert {
    condition     = google_bigquery_dataset.this.default_table_expiration_ms == null
    error_message = "default_table_expiration_ms must default to null so tables do not silently expire."
  }

  assert {
    condition     = length(google_bigquery_dataset.this.access) == 0
    error_message = "The module must not manage dataset access entries; an authoritative access block would strip grants made outside Terraform."
  }
}

run "no_cmek_block_when_key_unset" {
  assert {
    condition     = length(google_bigquery_dataset.this.default_encryption_configuration) == 0
    error_message = "default_encryption_configuration must be omitted when kms_key_name is null, leaving Google-managed keys in place."
  }
}

run "cmek_block_is_set_when_key_given" {
  variables {
    kms_key_name = "projects/test-project/locations/us/keyRings/bq/cryptoKeys/datasets"
  }

  assert {
    condition     = length(google_bigquery_dataset.this.default_encryption_configuration) == 1
    error_message = "default_encryption_configuration must be present when kms_key_name is set."
  }

  assert {
    condition     = google_bigquery_dataset.this.default_encryption_configuration[0].kms_key_name == "projects/test-project/locations/us/keyRings/bq/cryptoKeys/datasets"
    error_message = "kms_key_name must be passed through to default_encryption_configuration verbatim."
  }
}

run "accepts_expiration_of_one_day" {
  variables {
    default_table_expiration_ms = 86400000
  }

  assert {
    condition     = google_bigquery_dataset.this.default_table_expiration_ms == 86400000
    error_message = "A valid millisecond expiration must be passed through unchanged."
  }
}

# 3600 looks like "one hour" to anyone who assumes seconds. In milliseconds it
# is 3.6 seconds, which would expire live tables almost immediately.
run "rejects_expiration_that_looks_like_seconds" {
  command = plan

  variables {
    default_table_expiration_ms = 3600
  }

  expect_failures = [var.default_table_expiration_ms]
}

run "rejects_zero_expiration" {
  command = plan

  variables {
    default_table_expiration_ms = 0
  }

  expect_failures = [var.default_table_expiration_ms]
}

run "rejects_dataset_id_with_hyphen" {
  command = plan

  variables {
    dataset_id = "my-dataset"
  }

  expect_failures = [var.dataset_id]
}

run "rejects_malformed_kms_key_name" {
  command = plan

  variables {
    kms_key_name = "datasets"
  }

  expect_failures = [var.kms_key_name]
}
