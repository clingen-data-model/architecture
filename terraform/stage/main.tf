provider "google" {
  project = "clingen-stage"
  region  = "us-east1"
}

data "google_project" "current" {}

module "cloudbuild-firebase" {
  source            = "../modules/cloudbuild-firebase"
  project_id_number = data.google_project.current.number
  project_id        = data.google_project.current.project_id
}

# module "external-secrets" {
#   source     = "../modules/external-secrets"
#   env        = "stage"
#   project_id = data.google_project.current.project_id
# }

data "google_compute_default_service_account" "default_compute" {}

resource "google_project_iam_member" "default_compute_ar_read" {
  project = data.google_project.current.project_id
  role    = "roles/artifactregistry.reader"
  member  = data.google_compute_default_service_account.default_compute.member
}

resource "google_artifact_registry_repository" "genegraph-stage" {
  location      = "us-east1"
  repository_id = "genegraph-stage"
  description   = "repository for Genegraph containers"
  format        = "DOCKER"
}

resource "google_project_iam_member" "default_compute_sm_read" {
  project = data.google_project.current.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = data.google_compute_default_service_account.default_compute.member
}
