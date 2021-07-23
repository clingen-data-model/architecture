resource "google_storage_bucket_iam_member" "member" {
  bucket  = "clingen-tfstate-shared"
  role    = "roles/storage.objectAdmin"
  member  = "group:clingendevs@broadinstitute.org"
  project = "clingen-dx"
}

terraform {
  backend "gcs" {
    bucket = "clingen-tfstate-shared"
    prefix = "terraform/state"
  }
}
