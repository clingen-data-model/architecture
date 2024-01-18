provider "google" {
  region = "us-east1"
}

# project-level permissions that need to be consistent across all three environments
module "clingen_projects_iam_bindings" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "7.4.0"
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
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/bigquery.jobUser" = [
      "group:clingen-data-read@broadinstitute.org",
    ]

    "roles/bigquery.dataViewer" = [
      "group:clingen-data-read@broadinstitute.org",
    ]

    "roles/cloudbuild.builds.editor" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/cloudbuild.connectionAdmin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/cloudfunctions.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/run.invoker" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/cloudscheduler.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/container.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/compute.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
      "group:clingendevs@broadinstitute.org",
      "group:clingen-geisinger-external@broadinstitute.org",
    ]

    "roles/dns.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
      "group:clingendevs@broadinstitute.org",
      "group:clingen-geisinger-external@broadinstitute.org",
    ]

    "roles/firebase.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
    ]

    "roles/monitoring.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
      "group:clingendevs@broadinstitute.org",
      "group:clingen-geisinger-external@broadinstitute.org",
    ]

    "roles/pubsub.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
      "group:clingendevs@broadinstitute.org",
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
      "group:clingen-geisinger-external@broadinstitute.org",
    ]

    "roles/serviceusage.serviceUsageConsumer" = [
      "group:clingen-geisinger-external@broadinstitute.org",
    ]

    "roles/logging.admin" = [
      "group:clingen-gcp-admin@broadinstitute.org",
      "group:clingendevs@broadinstitute.org",
      "group:clingen-geisinger-external@broadinstitute.org",
    ]

    "roles/iam.securityReviewer" = [
      "group:clingendevs@broadinstitute.org",
      "group:clingen-geisinger-external@broadinstitute.org",
    ]

    "roles/iam.serviceAccountUser" = [
      "group:clingendevs@broadinstitute.org",
      "group:clingen-geisinger-external@broadinstitute.org",
    ]

    # beta, applied via GCP Console
    # "roles/iam.workloadIdentityPoolAdmin" = [
    #   "group:clingendevs@broadinstitute.org",
    # ]

    "roles/browser" = [
      "group:clingendevs@broadinstitute.org",
      "group:clingen-geisinger-external@broadinstitute.org",
    ]

    "roles/iap.tunnelResourceAccessor" = [
      "group:clingendevs@broadinstitute.org",
      "group:clingen-geisinger-external@broadinstitute.org",
    ]

    "roles/owner" = [
      "group:tgg-sre-admin@broadinstitute.org",
    ]

    "roles/workflows.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]
  }
}

# grants read access for specific storage buckets
module "clingen_storage_readers_iam" {
  source  = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  version = "7.4.0"
  mode    = "additive"

  storage_buckets = ["clinvar-reports"]

  bindings = {
    "roles/storage.objectViewer" = [
      "group:clingen-data-read@broadinstitute.org",
    ]
  }
}

module "nwc_storage_admins_iam" {
  source  = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  version = "7.4.0"
  mode    = "additive"

  storage_buckets = ["ga4gh-cvc-metakb"]

  bindings = {
    "roles/storage.objectAdmin" = [
      "user:Alex.Wagner@nationwidechildrens.org",
      "user:kori.kuzma@nationwidechildrens.org"
    ]
  }
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

# grants cloudbuild the cloudfunctions developer role and allows deployments
resource "google_project_iam_member" "stage_cloudbuild_cloudfunc_developer" {
  project = "clingen-stage"
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:583560269534@cloudbuild.gserviceaccount.com"
}

resource "google_service_account_iam_member" "stage_cloudbuild_cloudfunc_binding" {
  service_account_id = "projects/clingen-stage/serviceAccounts/clingen-stage@appspot.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:583560269534@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "prod_cloudbuild_cloudfunc_developer" {
  project = "clingen-dx"
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
}

resource "google_service_account_iam_member" "prod_cloudbuild_cloudfunc_binding" {
  service_account_id = "projects/clingen-dx/serviceAccounts/clingen-dx@appspot.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
}

resource "google_service_account" "clinvar-ingest-deployment" {
  account_id   = "clinvar-ingest-deployment"
  display_name = "Clinvar Ingest Deployment"
  project      = "clingen-dev"
}

resource "google_project_iam_custom_role" "custom-bucket-list-role" {
  role_id     = "BucketList"
  title       = "Custom Role for listing buckets"
  description = "A role that allows for listing buckets"
  permissions = ["storage.buckets.list"]
  project = "clingen-dev"
}

resource "google_project_iam_member" "clinvar-ingest-service-usage" {
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.clinvar-ingest-deployment.email}"
  project = "clingen-dev"
}

resource "google_project_iam_member" "clinvar-ingest-cloudbuild" {
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.clinvar-ingest-deployment.email}"
  project = "clingen-dev"
}

resource "google_project_iam_member" "clinvar-ingest-workflows" {
  role   = "roles/workflows.editor"
  member  = "serviceAccount:${google_service_account.clinvar-ingest-deployment.email}"
  project = "clingen-dev"
}

resource "google_project_iam_member" "clinvar-ingest-bucket-list" {
  role    = "${google_project_iam_custom_role.custom-bucket-list-role.id}"
  member  = "serviceAccount:${google_service_account.clinvar-ingest-deployment.email}"
  project = "clingen-dev"
}

resource "google_storage_bucket_iam_member" "clinvar-ingest-build-logs" {
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.clinvar-ingest-deployment.email}"
  bucket = "clinvar-ingest"
}

resource "google_storage_bucket_iam_member" "clinvar-ingest-cloudbuild-storage" {
  role = "roles/storage.legacyBucketWriter"
  member = "serviceAccount:${google_service_account.clinvar-ingest-deployment.email}"
  bucket = "clingen-dev_cloudbuild"
}

resource "google_cloud_run_service_iam_member" "clinvar-ingest-cloudrun-editor" {
  role = "roles/run.developer"
  member = "serviceAccount:${google_service_account.clinvar-ingest-deployment.email}"
  service = "clinvar-ingest"
  project = "clingen-dev"
  location = "us-central1"
}

resource "google_service_account_iam_member" "clinvar-ingest-service-account-user" {
  service_account_id  = "projects/clingen-dev/serviceAccounts/522856288592-compute@developer.gserviceaccount.com"
  role                = "roles/iam.serviceAccountUser"
  member              = "serviceAccount:${google_service_account.clinvar-ingest-deployment.email}"
}

module "gh_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  version     = "3.1.0"
  project_id  = "clingen-dev"
  pool_id     = "clingen-actions-pool"
  provider_id = "clingen-github-actions"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }
  attribute_condition = "assertion.ref=='refs/heads/main'"
  sa_mapping = {
    "${google_service_account.clinvar-ingest-deployment.account_id}" = {
      sa_name   = google_service_account.clinvar-ingest-deployment.id
      attribute = "attribute.repository/clingen-data-model/clinvar-ingest"
    }
  }
}

# clinvar-ingest-pipeline service account configuration
resource "google_service_account" "clinvar-ingest-pipeline" {
  project = "clingen-dx"
  account_id   = "clinvar-ingest-pipeline"
  display_name = "Service account for clinvar-ingest pipeline components"
}
resource "google_project_iam_member" "clinvar-ingest-pipeline-bigquery-admin" {
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.clinvar-ingest-pipeline.email}"
  project = "clingen-dev"
}
resource "google_project_iam_member" "clinvar-ingest-pipeline-cloudrun-invoker" {
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.clinvar-ingest-pipeline.email}"
  project = "clingen-dev"
}
resource "google_project_iam_member" "clinvar-ingest-pipeline-workflows-invoker" {
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.clinvar-ingest-pipeline.email}"
  project = "clingen-dev"
}
resource "google_project_iam_member" "clinvar-ingest-pipeline-storage-object-creator" {
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_service_account.clinvar-ingest-pipeline.email}"
  project = "clingen-dev"
}
resource "google_project_iam_member" "clinvar-ingest-pipeline-storage-object-viewer" {
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.clinvar-ingest-pipeline.email}"
  project = "clingen-dev"
}
