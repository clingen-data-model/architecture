terraform {
  required_version = ">= 1.0.0, < 1.1.0"

  backend "gcs" {
    bucket = "clingen-tfstate-shared"
    prefix = "terraform/kafka_backups/state"
  }
}
