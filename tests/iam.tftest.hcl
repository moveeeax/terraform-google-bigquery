# Dataset IAM grants. Runs offline against a mocked google provider; needs
# Terraform/OpenTofu >= 1.7 for mock_provider (the module itself supports >= 1.5).

mock_provider "google" {}

variables {
  project_id = "test-project"
  dataset_id = "analytics"
}

# Upgrading must not add resources to an existing deployment's plan.
run "no_grants_by_default" {
  command = plan

  assert {
    condition     = length(google_bigquery_dataset_iam_member.this) == 0
    error_message = "iam_members defaults to empty, so no IAM member resources may be planned."
  }

  assert {
    condition     = length(google_bigquery_dataset.this.access) == 0
    error_message = "The dataset must still declare no authoritative access block."
  }
}

run "one_resource_per_role_member_pair" {
  command = plan

  variables {
    iam_members = {
      "roles/bigquery.dataViewer" = [
        "group:analysts@example.com",
        "serviceAccount:etl@test-project.iam.gserviceaccount.com",
        "group:analysts@example.com",
      ]
      "roles/bigquery.dataEditor" = ["serviceAccount:etl@test-project.iam.gserviceaccount.com"]
    }
  }

  assert {
    condition     = length(google_bigquery_dataset_iam_member.this) == 3
    error_message = "Each distinct role/member pair must become exactly one grant; duplicates collapse."
  }

  assert {
    condition     = google_bigquery_dataset_iam_member.this["roles/bigquery.dataViewer group:analysts@example.com"].role == "roles/bigquery.dataViewer"
    error_message = "Grants must be keyed by \"role member\" and carry the role."
  }

  assert {
    condition     = google_bigquery_dataset_iam_member.this["roles/bigquery.dataEditor serviceAccount:etl@test-project.iam.gserviceaccount.com"].member == "serviceAccount:etl@test-project.iam.gserviceaccount.com"
    error_message = "Grants must carry the member verbatim."
  }

  assert {
    condition     = alltrue([for g in google_bigquery_dataset_iam_member.this : g.dataset_id == "analytics" && g.project == "test-project"])
    error_message = "Every grant must target this module's dataset."
  }

  assert {
    condition     = length(google_bigquery_dataset.this.access) == 0
    error_message = "Adding grants must not introduce an authoritative access block on the dataset."
  }
}

run "accepts_custom_role" {
  command = plan

  variables {
    iam_members = {
      "projects/test-project/roles/bqReader" = ["user:jane@example.com"]
    }
  }

  assert {
    condition     = length(google_bigquery_dataset_iam_member.this) == 1
    error_message = "A project-level custom role must be accepted."
  }
}

run "rejects_legacy_role" {
  command = plan

  variables {
    iam_members = { READER = ["user:jane@example.com"] }
  }

  expect_failures = [var.iam_members]
}

run "rejects_member_without_type_prefix" {
  command = plan

  variables {
    iam_members = { "roles/bigquery.dataViewer" = ["jane@example.com"] }
  }

  expect_failures = [var.iam_members]
}

run "rejects_public_grant" {
  command = plan

  variables {
    iam_members = { "roles/bigquery.dataViewer" = ["allUsers"] }
  }

  expect_failures = [var.iam_members]
}

run "rejects_all_authenticated_users" {
  command = plan

  variables {
    iam_members = { "roles/bigquery.dataViewer" = ["allAuthenticatedUsers"] }
  }

  expect_failures = [var.iam_members]
}
