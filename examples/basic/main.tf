terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "bigquery" {
  source = "../.."

  project_id = var.project_id
  dataset_id = "example_dataset"
  location   = "US"

  labels = {
    environment = "sandbox"
  }
}

variable "project_id" {
  description = "Project ID to deploy the example dataset into."
  type        = string
}

variable "region" {
  description = "Region for the google provider."
  type        = string
  default     = "us-central1"
}

output "dataset_id" {
  value = module.bigquery.dataset_id
}
