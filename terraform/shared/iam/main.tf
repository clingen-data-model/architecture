provider "google" {
  region = "us-east1"
}

# project-level permissions that need to be consistent across all three environments
module "clingen_projects_iam_bindings" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "7.2.0"
  mode    = "additive"

  projects = ["clingen-dx", "clingen-stage", "clingen-dev"]

  bindings = {

    "roles/appengine.appAdmin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/appengine.appCreator" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/bigquery.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/cloudbuild.builds.editor" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/cloudfunctions.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/cloudscheduler.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/container.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/compute.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/dns.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/firebase.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/monitoring.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/pubsub.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/run.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/iam.serviceAccountAdmin" = [
      "group:clingen-gcp-admin@broadinstitute.org"
    ]

    "roles/serviceusage.apiKeysAdmin" = [
      "group:clingen-gcp-admin@broadinstitute.org"
    ]

    "roles/storage.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
      "group:clingendevs@broadinstitute.org",
    ]

  }
}

# grants read access for specific storage buckets
module "clingen_storage_readers_iam" {
  source  = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  version = "7.2.0"
  mode    = "additive"

  storage_buckets = ["clinvar-reports"]

  bindings = {
    "roles/storage.objectViewer" = [
      "group:clingen-data-read@broadinstitute.org",
    ]
  }
}

resource "google_project_iam_member" "clingen_bigquery_prod_readers" {
  project = "clingen-dx"
  role    = "roles/bigquery.dataViewer"
  member  = "group:clingen-data-read@broadinstitute.org"
}

resource "google_project_iam_member" "clingen_bigquery_prod_cxn_users" {
  project = "clingen-dx"
  role    = "roles/bigquery.jobUser"
  member  = "group:clingen-data-read@broadinstitute.org"
}


resource "google_project_iam_member" "clingen_bigquery_dev_readers" {
  project = "clingen-dev"
  role    = "roles/bigquery.dataViewer"
  member  = "group:clingen-data-read@broadinstitute.org"
}

resource "google_project_iam_member" "clingen_bigquery_dev_cxn_users" {
  project = "clingen-dev"
  role    = "roles/bigquery.jobUser"
  member  = "group:clingen-data-read@broadinstitute.org"
}

resource "google_project_iam_custom_role" "cloudfunction_unauthed_perms" {
  project     = "clingen-dx"
  role_id     = "cloudbuildFunctionIamManager"
  title       = "IAM Policy Manager for CloudFunctions"
  description = "Allows for updating the IAM policy on cloudfunctions to enable unauthenticated functions"
  permissions = ["cloudfunctions.functions.setIamPolicy", "cloudfunctions.functions.getIamPolicy"]
}

resource "google_project_iam_member" "cloudbuild_iam_manager" {
  project = "clingen-dx"
  role    = google_project_iam_custom_role.cloudfunction_unauthed_perms.name
  member  = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
}
