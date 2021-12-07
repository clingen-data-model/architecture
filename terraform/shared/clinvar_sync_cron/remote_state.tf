terraform {
  required_version = ">= 1.0.0, < 1.1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.3.0"
    }
  }

  backend "gcs" {
    bucket = "clingen-tfstate-shared"
    prefix = "terraform/clinvar_sync_cron/state"
  }
}
