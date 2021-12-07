provider "google" {
  region  = "us-east1"
  project = "clingen-stage"
}

data "google_project" "current" {}

resource "google_service_account" "clinvar_bigquery_updater" {
  account_id   = "clinvar-bq-updater"
  display_name = "Cron Job for updating clinvar ingest data"
}

resource "google_project_iam_binding" "project" {
  project = data.google_project.current.project_id
  role    = "roles/bigquery.dataEditor"

  members = [
    "serviceAccount:${google_service_account.clinvar_bigquery_updater.email}",
  ]
}

resource "google_project_iam_binding" "bq_jobuser" {
  project = data.google_project.current.project_id
  role    = "roles/bigquery.jobUser"

  members = [
    "serviceAccount:${google_service_account.clinvar_bigquery_updater.email}",
  ]
}

resource "google_bigquery_dataset_iam_binding" "dx_clinvar_writer" {
  dataset_id = "clinvar_qa"
  role       = "roles/bigquery.dataEditor"
  project    = "clingen-dx"

  members = [
    "serviceAccount:${google_service_account.clinvar_bigquery_updater.email}",
  ]
}

