provider "google" {
  project = "clingen-dx"
  region  = "us-east1"
}

module "external-secrets" {
  source = "../modules/external-secrets"
  env    = "prod"
}

module "prod-gke-cluster" {
  source                    = "github.com/broadinstitute/tgg-terraform-modules//imported-gke-cluster?ref=26fcbffd5441e69e2b3e5fb6fe4e66d0e66a0bbc"
  cluster_name              = "prod-cluster"
  cluster_location          = "us-east1-b"
  network_id                = "projects/clingen-dx/global/networks/default"
  subnetwork_id             = "projects/clingen-dx/regions/us-east1/subnetworks/default"
  maint_start_time          = "2021-03-02T11:00:00Z"
  maint_end_time            = "2021-03-02T23:00:00Z"
  maint_recurrence_sched    = "FREQ=WEEKLY;BYDAY=SA,SU"
  initial_node_count        = 0
  default_pool_node_count   = 3
  default_pool_machine_type = "n2-standard-4"
  cluster_v4_cidr           = "10.0.0.0/14"
  services_v4_cidr          = "10.4.0.0/20"
  resource_labels = {
    admin      = "steve"
    managed_by = "terraform"
  }
}

# IAM bindings for the clinvarSCV cloud functions
resource "google_service_account_iam_member" "cloudbuild_appspot_binding" {
  service_account_id = "projects/clingen-dx/serviceAccounts/clingen-dx@appspot.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_cloudfunctions_grant" {
  role   = "roles/cloudfunctions.developer"
  member = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
}

# IAM binding for allowing staging clinvarSCV function to run prod bigquery
resource "google_bigquery_dataset_iam_member" "stage_appspot_sa" {
  dataset_id = "clinvar_qa"
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:clingen-stage@appspot.gserviceaccount.com"
}
