# configs for managing access to the terraform state bucket

resource "google_storage_bucket_iam_member" "member" {
  bucket = "clingen-tfstate-dev"
  role   = "roles/storage.objectAdmin"
  member = "group:clingendevs@broadinstitute.org"
}

terraform {
  backend "gcs" {
    bucket = "clingen-tfstate-dev"
    prefix = "terraform/state"
  }
}
