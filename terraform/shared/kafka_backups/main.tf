provider "google" {
  region  = "us-east1"
  project = "clingen-dx"
}

resource "google_storage_bucket" "confluent_backups_test" {
  name          = "clingen-confluent-backups-test"
  location      = "us-east1"
  storage_class = "REGIONAL"
}
