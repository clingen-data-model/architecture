terraform {
  backend "gcs" {
    bucket = "clingen-tfstate-shared"
    prefix = "terraform/mondo_notifier/state"
  }
}
