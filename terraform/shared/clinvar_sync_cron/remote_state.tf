terraform {
  backend "gcs" {
    bucket = "clingen-tfstate-shared"
    prefix = "terraform/clinvar_sync_cron/state"
  }
}
