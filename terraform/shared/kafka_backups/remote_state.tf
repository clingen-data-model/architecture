terraform {
  backend "gcs" {
    bucket = "clingen-tfstate-shared"
    prefix = "terraform/kafka_backups/state"
  }
}
