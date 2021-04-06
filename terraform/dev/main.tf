provider "google" {
  project = "clingen-dev"
  region  = "us-east1"
}

module "external-secrets" {
  source = "../modules/external-secrets"
  env    = "dev"
}

module "cloudbuild-firebase" {
  source = "../modules/cloudbuild-firebase"
  project_id_number = "522856288592"
}
