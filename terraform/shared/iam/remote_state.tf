resource "google_storage_bucket_iam_member" "member" {
  bucket = "clingen-tfstate-shared"
  role   = "roles/storage.objectAdmin"
  member = "group:clingendevs@broadinstitute.org"
}

terraform {
  backend "gcs" {
    bucket = "clingen-tfstate-shared"
    prefix = "terraform/iam/state"
  }
}
