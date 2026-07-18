variable "project_id" {
  description = "ID of the project in which to create the dataset."
  type        = string
}

variable "dataset_id" {
  description = "Unique dataset id within the project."
  type        = string
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
  description = "Default lifetime of tables in milliseconds. Null disables expiration."
  type        = number
  default     = null
}

variable "delete_contents_on_destroy" {
  description = "Whether to delete all tables when the dataset is destroyed."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels applied to the dataset."
  type        = map(string)
  default     = {}
}
