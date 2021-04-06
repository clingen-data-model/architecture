provider "google" {
  project = "clingen-stage"
  region  = "us-east1"
}

module "cloudbuild-firebase" {
  source = "../modules/cloudbuild-firebase"
  project_id_number = "583560269534"
}
