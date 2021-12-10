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

module "dev-gke-cluster" {
  source                    = "github.com/broadinstitute/tgg-terraform-modules//imported-gke-cluster?ref=ce78edb118f2cd4bdb9d0adec33aa323b92f7a2f"
  cluster_name              = "genegraph-dev"
  cluster_location          = "us-east1-b"
  network_id                = "projects/clingen-dev/global/networks/default"
  subnetwork_id             = "projects/clingen-dev/regions/us-east1/subnetworks/default"
  maint_start_time          = "2021-03-24T11:00:00Z"
  maint_end_time            = "2021-03-24T23:00:00Z"
  maint_recurrence_sched    = "FREQ=WEEKLY;BYDAY=SA,SU"
  initial_node_count        = 0
  default_pool_node_count   = 2
  default_pool_machine_type = "n1-highmem-2"
  cluster_v4_cidr           = "10.36.0.0/14"
  services_v4_cidr          = "10.101.0.0/20"
  resource_labels = {
    admin      = "terry"
    creator    = "terry"
    managed_by = "terraform"
  }
}
