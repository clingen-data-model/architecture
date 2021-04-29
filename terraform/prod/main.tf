provider "google" {
  project = "clingen-dx"
  region  = "us-east1"
}

module "external-secrets" {
  source = "../modules/external-secrets"
  env    = "prod"
}

module "prod-gke-cluster" {
  source                    = "git@github.com:broadinstitute/tgg-terraform-modules.git//imported-gke-cluster?ref=26fcbffd5441e69e2b3e5fb6fe4e66d0e66a0bbc"
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
