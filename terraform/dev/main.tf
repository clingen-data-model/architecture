provider "google" {
  project = "clingen-dev"
  region  = "us-east1"
}

data "google_project" "current" {}

module "external-secrets" {
  source     = "../modules/external-secrets"
  env        = "dev"
  project_id = data.google_project.current.project_id
}

module "cloudbuild-firebase" {
  source            = "../modules/cloudbuild-firebase"
  project_id_number = data.google_project.current.number
  project_id        = data.google_project.current.project_id
}

data "google_compute_default_service_account" "default_compute" {}

resource "google_project_iam_member" "default_compute_ar_read" {
  project = data.google_project.current.project_id
  role    = "roles/artifactregistry.reader"
  member  = data.google_compute_default_service_account.default_compute.member
}

resource "google_project_iam_member" "default_compute_sm_read" {
  project = data.google_project.current.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = data.google_compute_default_service_account.default_compute.member
}

resource "google_project_iam_member" "bigquery_dev_read_miscast" {
  project = data.google_project.current.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "serviceAccount:clinvar-update-sa@miscast.iam.gserviceaccount.com"
}
