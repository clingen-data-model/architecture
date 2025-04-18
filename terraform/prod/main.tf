provider "google" {
  project = "clingen-dx"
  region  = "us-east1"
}

data "google_project" "current" {}

module "external-secrets" {
  source     = "../modules/external-secrets"
  env        = "prod"
  project_id = data.google_project.current.project_id
}

data "google_compute_default_service_account" "default_compute" {}

resource "google_project_iam_member" "default_compute_ar_read" {
  project = data.google_project.current.project_id
  role    = "roles/artifactregistry.reader"
  member  = data.google_compute_default_service_account.default_compute.member
}

resource "google_artifact_registry_repository" "genegraph-prod" {
  location      = "us-east1"
  repository_id = "genegraph-prod"
  description   = "repository for Genegraph containers"
  format        = "DOCKER"
}

module "prod-gke-cluster" {
  source                   = "github.com/broadinstitute/tgg-terraform-modules//imported-gke-cluster?ref=1679ea8bb0fedfb879bca581624c6c51df6efbfa"
  cluster_name             = "prod-cluster"
  cluster_location         = "us-east1-b"
  network_id               = "projects/clingen-dx/global/networks/default"
  subnetwork_id            = "projects/clingen-dx/regions/us-east1/subnetworks/default"
  maint_start_time         = "2021-03-02T11:00:00Z"
  maint_end_time           = "2021-03-02T23:00:00Z"
  maint_recurrence_sched   = "FREQ=WEEKLY;BYDAY=SA,SU"
  initial_node_count       = 0
  remove_default_node_pool = true
  cluster_v4_cidr          = "10.0.0.0/14"
  services_v4_cidr         = "10.4.0.0/20"
  resource_labels = {
    admin      = "steve"
    managed_by = "terraform"
  }
}

resource "google_container_node_pool" "main-node-pool" {
  name       = "main-node-pool"
  location   = "us-east1-b"
  cluster    = module.prod-gke-cluster.gke-cluster-name
  node_count = 4

  node_config {
    preemptible     = false
    machine_type    = "n2-standard-4"
    image_type      = "COS_CONTAINERD"
    ephemeral_storage_local_ssd_config {    
      local_ssd_count = 1
    }
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_container_node_pool" "prod-arm-ssd-node-pool" {
  name       = "prod-arm-ssd-node-pool"
  location   = "us-east1-b"
  cluster    = module.prod-gke-cluster.gke-cluster-name
  node_count = 1
  node_config {
    preemptible     = false
    machine_type    = "c4a-highmem-4-lssd"
    image_type      = "COS_CONTAINERD"
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}



# IAM bindings for the clinvarSCV cloud functions
resource "google_service_account_iam_member" "cloudbuild_appspot_binding" {
  service_account_id = "projects/clingen-dx/serviceAccounts/clingen-dx@appspot.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
}

resource "google_service_account_iam_member" "cloudbuild_actas" {
  service_account_id = "projects/clingen-dx/serviceAccounts/974091131481-compute@developer.gserviceaccount.com"
  member             = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
}

resource "google_project_iam_member" "cloudbuild_cloudfunctions_grant" {
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
  project = data.google_project.current.project_id
}

resource "google_project_iam_member" "cloudbuild_cloudrun_admin_grant" {
  role    = "roles/run.admin"
  member  = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
  project = data.google_project.current.project_id
}

# IAM binding for allowing staging clinvarSCV function to run prod bigquery
resource "google_bigquery_dataset_iam_member" "stage_appspot_sa" {
  dataset_id = "clinvar_qa"
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:clingen-stage@appspot.gserviceaccount.com"
}

resource "google_bigquery_dataset_iam_member" "stage_compute_bigquery_viewer" {
  dataset_id = "clinvar_qa"
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:583560269534-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "stage_compute_bq_user" {
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:583560269534-compute@developer.gserviceaccount.com"
  project = data.google_project.current.project_id
}

# IAM bindings to allow prod scv function to read the bq dataset
resource "google_bigquery_dataset_iam_member" "prod_compute_bigquery_viewer" {
  dataset_id = "clinvar_qa"
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:974091131481-compute@developer.gserviceaccount.com"
}

resource "google_project_iam_member" "prod_compute_bq_user" {
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:974091131481-compute@developer.gserviceaccount.com"
  project = data.google_project.current.project_id
}

resource "google_project_iam_member" "default_compute_sm_read" {
  project = data.google_project.current.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = data.google_compute_default_service_account.default_compute.member
}

resource "google_project_iam_member" "cloudbuild_sm_read" {
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
  project = data.google_project.current.project_id
}
