provider "google" {
  region  = "us-east1"
  project = "clingen-stage"
}

resource "google_service_account" "clinvar_bigquery_updater" {
  account_id   = "clinvar-bq-updater"
  display_name = "Cron Job for updating clinvar ingest data"
}

resource "google_project_iam_binding" "project" {
  project = "clingen-stage"
  role    = "roles/bigquery.dataEditor"

  members = [
    "serviceAccount:${google_service_account.clinvar_bigquery_updater.email}",
  ]
}

resource "google_project_iam_binding" "bq_jobuser" {
  project = "clingen-stage"
  role    = "roles/bigquery.jobUser"

  members = [
    "serviceAccount:${google_service_account.clinvar_bigquery_updater.email}",
  ]
}
