provider "google" {
  project = "clingen-dev"
  region  = "us-east1"
}

module "external-secrets" {
  source = "../modules/external-secrets"
  env    = "dev"
}

module "cloudbuild-firebase" {
  source            = "../modules/cloudbuild-firebase"
  project_id_number = "522856288592"
}

module "dev-gke-cluster" {
  source                    = "git@github.com:broadinstitute/tgg-terraform-modules.git//imported-gke-cluster?ref=de68768bedf1c37cc81d2e696d673f75dc70d1d7"
  cluster_name                      = "genegraph-dev"
  cluster_location          = "us-east1-b"
  network_id                   = "projects/clingen-dev/global/networks/default"
  subnetwork_id                = "projects/clingen-dev/regions/us-east1/subnetworks/default"
  maint_start_time          = "2021-03-24T11:00:00Z"
  maint_end_time            = "2021-03-24T23:00:00Z"
  maint_recurrence_sched    = "FREQ=WEEKLY;BYDAY=SA,SU"
  default_pool_node_count   = 2
  default_pool_machine_type = "n1-highmem-2"
  cluster_v4_cidr           = "10.36.0.0/14"
  services_v4_cidr          = "10.101.0.0/20"
  resource_labels = {
    admin = "terry, steve"
    creator = "terry"
    managed_by = "terraform"
  }
}
