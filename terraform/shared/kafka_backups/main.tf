provider "google" {
  region  = "us-east1"
  project = "clingen-dx"
}

resource "google_storage_bucket" "confluent_backups" {
  name          = "clingen-confluent-backups"
  location      = "us-east1"
  storage_class = "REGIONAL"
}

resource "google_service_account" "confluent_cloud_backups_owner" {
  account_id   = "confluent-cloud-kakfa-backups"
  display_name = "Confluent Cloud GCS Sink Account"
}

resource "google_storage_bucket_iam_binding" "backups_sa_binding" {
  bucket = google_storage_bucket.confluent_backups.name
  role   = "roles/storage.admin"
  members = [
    "serviceAccount:${google_service_account.confluent_cloud_backups_owner.email}",
  ]
}
