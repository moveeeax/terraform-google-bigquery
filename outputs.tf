output "id" {
  description = "Identifier of the dataset."
  value       = google_bigquery_dataset.this.id
}

output "dataset_id" {
  description = "Dataset id within the project."
  value       = google_bigquery_dataset.this.dataset_id
}

output "self_link" {
  description = "URI of the dataset."
  value       = google_bigquery_dataset.this.self_link
}
