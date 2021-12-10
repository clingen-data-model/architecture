# configs for managing access to the terraform state bucket

resource "google_storage_bucket_iam_member" "member" {
  bucket  = "clingen-tfstate-prod"
  role    = "roles/storage.objectAdmin"
  member  = "group:clingendevs@broadinstitute.org"
}

terraform {
  required_version = ">= 1.0.0, < 1.1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.3.0"
    }
  }


  backend "gcs" {
    bucket = "clingen-tfstate-prod"
    prefix = "terraform/state"
  }
}
