provider "google" {
  project = "clingen-stage"
  region  = "us-east1"
}

module "cloudbuild-firebase" {
  source            = "../modules/cloudbuild-firebase"
  project_id_number = "583560269534"
}

module "external-secrets" {
  source = "../modules/external-secrets"
  env    = "stage"
}

module "stage-gke-cluster" {
  source                    = "git@github.com:broadinstitute/tgg-terraform-modules.git//imported-gke-cluster?ref=ce78edb118f2cd4bdb9d0adec33aa323b92f7a2f"
  cluster_name              = "stage-cluster"
  cluster_location          = "us-east1-b"
  network_id                = "projects/clingen-stage/global/networks/default"
  subnetwork_id             = "projects/clingen-stage/regions/us-east1/subnetworks/default"
  maint_start_time          = "2021-03-24T11:00:00Z"
  maint_end_time            = "2021-03-24T23:00:00Z"
  maint_recurrence_sched    = "FREQ=WEEKLY;BYDAY=SA,SU"
  initial_node_count        = 0
  default_pool_node_count   = 0 # no default node pool, see ssd-pool below
  default_pool_machine_type = "n1-standard-4"
  cluster_v4_cidr           = "10.56.0.0/14"
  services_v4_cidr          = "10.0.16.0/20"
  resource_labels = {
    admin      = "tristan"
    creator    = "tristan"
    managed_by = "terraform"
  }
}

# stage cluster has no default pool, but does have a custom ssd-pool
resource "google_container_node_pool" "ssd-pool" {
  name       = "ssd-pool"
  location   = "us-east-1b"
  cluster    = module.stage-gke-cluster.google_container_cluster.cluster.name
  node_count = 2

  node_config {
    preemptible  = false
    machine_type = "n1-standard-4"
  }
}
