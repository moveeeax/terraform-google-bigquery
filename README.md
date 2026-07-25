# terraform-google-bigquery

Terraform module that manages a [Google Cloud](https://cloud.google.com/)
BigQuery dataset (`google_bigquery_dataset`). It creates a single dataset with
configurable location, default table expiration and labels.

## Usage

```hcl
module "bigquery" {
  source = "github.com/moveeeax/terraform-google-bigquery"

  project_id = var.project_id
  dataset_id = "analytics"
  location   = "US"

  labels = {
    team = "data"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

### Customer-managed encryption (CMEK)

BigQuery encrypts every dataset at rest with Google-managed keys by default. To
hold the keys yourself, pass a Cloud KMS key in the same location as the
dataset. Grant the project's BigQuery service account
`roles/cloudkms.cryptoKeyEncrypterDecrypter` on that key *before* applying, or
the create call fails.

```hcl
module "bigquery" {
  source = "github.com/moveeeax/terraform-google-bigquery"

  project_id   = var.project_id
  dataset_id   = "analytics"
  location     = "US"
  kms_key_name = "projects/my-project/locations/us/keyRings/bq/cryptoKeys/datasets"
}
```

## Behaviour worth knowing

- **`delete_contents_on_destroy` defaults to `false`.** With the default,
  `terraform destroy` refuses to remove a dataset that still holds tables. Set
  it to `true` only for datasets whose contents are disposable — once set,
  destroying the dataset drops every table in it with no further prompt.
- **`default_table_expiration_ms` is in MILLISECONDS.** One hour is `3600000`,
  one day `86400000`, 30 days `2592000000`. A value that was meant to be seconds
  expires live tables far earlier than intended, so the module rejects anything
  below BigQuery's one-hour floor. It applies to tables created *after* the
  value is set; existing tables keep the expiry they were created with.
- **This module does not manage dataset access.** It deliberately sets no
  `access` block, because that block is authoritative: declaring it would make
  Terraform delete every grant added outside this module, including the default
  owner entries BigQuery creates with the dataset. Grant access alongside the
  module with the additive `google_bigquery_dataset_iam_member` /
  `google_bigquery_dataset_iam_binding` resources. Never grant `allUsers` or
  `allAuthenticatedUsers` — that makes the data public to the internet.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| google    | >= 5.0   |

## Inputs

| Name                          | Description                                              | Type          | Default                  | Required |
|-------------------------------|----------------------------------------------------------|---------------|--------------------------|:--------:|
| `project_id`                  | ID of the project in which to create the dataset.        | `string`      | n/a                      |   yes    |
| `dataset_id`                  | Dataset id. Letters, numbers and underscores only.       | `string`      | n/a                      |   yes    |
| `friendly_name`               | Human-readable name for the dataset.                     | `string`      | `null`                   |    no    |
| `description`                 | Description of the dataset.                              | `string`      | `"Managed by Terraform"` |    no    |
| `location`                    | Geographic location of the dataset.                      | `string`      | `"US"`                   |    no    |
| `default_table_expiration_ms` | Default lifetime of new tables, in **milliseconds**. Minimum `3600000`. | `number` | `null`      |    no    |
| `delete_contents_on_destroy`  | Allow `terraform destroy` to drop a dataset that still has tables. | `bool` | `false`          |    no    |
| `kms_key_name`                | Cloud KMS key for CMEK encryption. Null uses Google-managed keys. | `string` | `null`             |    no    |
| `labels`                      | Labels applied to the dataset.                           | `map(string)` | `{}`                     |    no    |

## Outputs

| Name         | Description                     |
|--------------|---------------------------------|
| `id`         | Identifier of the dataset.     |
| `dataset_id` | Dataset id within the project. |
| `self_link`  | URI of the dataset.            |

## Tests

The module has a unit test suite that runs against a mocked provider — no
credentials, no project and no network access needed:

```sh
terraform init -backend=false
terraform test
```

`terraform test` with `mock_provider` needs Terraform (or OpenTofu) >= 1.7. That
is a requirement of the test suite only; the module itself still supports
>= 1.5.

## License

[MIT](LICENSE)
