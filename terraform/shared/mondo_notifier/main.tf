provider "google" {
  region  = "us-east1"
  project = "clingen-dx"
}

data "google_project" "current" {}

resource "google_service_account" "mondo_notifier_func" {
  account_id   = "clingen-mondo-notify"
  display_name = "Cloud function for notifying on new mondo releases"
}

# allows for automated cloudbuild deployments
resource "google_service_account_iam_member" "cloudbuild_mondo_notifier_binding" {
  service_account_id = "projects/clingen-dx/serviceAccounts/${google_service_account.mondo_notifier_func.email}"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
}

resource "google_cloudbuild_trigger" "mondo_notifier_repo" {
  name        = "mondo-notifier-push"
  description = "Redeploy mondo notifier function on push to main"

  github {
    name  = "mondo-notifier"
    owner = "clingen-data-model"
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}
