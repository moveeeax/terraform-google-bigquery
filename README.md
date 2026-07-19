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

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| google    | >= 5.0   |

## Inputs

| Name                          | Description                                              | Type          | Default                  | Required |
|-------------------------------|----------------------------------------------------------|---------------|--------------------------|:--------:|
| `project_id`                  | ID of the project in which to create the dataset.        | `string`      | n/a                      |   yes    |
| `dataset_id`                  | Unique dataset id within the project.                    | `string`      | n/a                      |   yes    |
| `friendly_name`               | Human-readable name for the dataset.                     | `string`      | `null`                   |    no    |
| `description`                 | Description of the dataset.                              | `string`      | `"Managed by Terraform"` |    no    |
| `location`                    | Geographic location of the dataset.                      | `string`      | `"US"`                   |    no    |
| `default_table_expiration_ms` | Default lifetime of tables in milliseconds.              | `number`      | `null`                   |    no    |
| `delete_contents_on_destroy`  | Whether to delete all tables on destroy.                 | `bool`        | `false`                  |    no    |
| `labels`                      | Labels applied to the dataset.                           | `map(string)` | `{}`                     |    no    |

## Outputs

| Name         | Description                     |
|--------------|---------------------------------|
| `id`         | Identifier of the dataset.     |
| `dataset_id` | Dataset id within the project. |
| `self_link`  | URI of the dataset.            |

## License

[MIT](LICENSE)
