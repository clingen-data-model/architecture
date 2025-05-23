provider "google" {
  project = "clingen-stage"
  region  = "us-east1"
}

data "google_project" "current" {}

module "cloudbuild-firebase" {
  source            = "../modules/cloudbuild-firebase"
  project_id_number = data.google_project.current.number
  project_id        = data.google_project.current.project_id
}

module "external-secrets" {
  source     = "../modules/external-secrets"
  env        = "stage"
  project_id = data.google_project.current.project_id
}

data "google_compute_default_service_account" "default_compute" {}

resource "google_project_iam_member" "default_compute_ar_read" {
  project = data.google_project.current.project_id
  role    = "roles/artifactregistry.reader"
  member  = data.google_compute_default_service_account.default_compute.member
}

resource "google_artifact_registry_repository" "genegraph-stage" {
  location      = "us-east1"
  repository_id = "genegraph-stage"
  description   = "repository for Genegraph containers"
  format        = "DOCKER"
}

module "stage-gke-cluster" {
  source                   = "github.com/broadinstitute/tgg-terraform-modules//imported-gke-cluster?ref=1679ea8bb0fedfb879bca581624c6c51df6efbfa"
  cluster_name             = "stage-cluster"
  cluster_location         = "us-east1-b"
  network_id               = "projects/clingen-stage/global/networks/default"
  subnetwork_id            = "projects/clingen-stage/regions/us-east1/subnetworks/default"
  maint_start_time         = "2021-03-24T11:00:00Z"
  maint_end_time           = "2021-03-24T23:00:00Z"
  maint_recurrence_sched   = "FREQ=WEEKLY;BYDAY=SA,SU"
  initial_node_count       = 0
  remove_default_node_pool = true
  cluster_v4_cidr          = "10.56.0.0/14"
  services_v4_cidr         = "10.0.16.0/20"
  resource_labels = {
    admin      = "tristan"
    creator    = "tristan"
    managed_by = "terraform"
  }
}

# resource "google_container_node_pool" "main-node-pool" {
#   name       = "main-node-pool"
#   location   = "us-east1-b"
#   cluster    = module.stage-gke-cluster.gke-cluster-name
#   node_count = 4

#   node_config {
#     preemptible     = false
#     machine_type    = "n2-standard-4"
#     image_type      = "COS_CONTAINERD"
#     ephemeral_storage_local_ssd_config {    
#       local_ssd_count = 1
#     }
#     oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
#   }
# }

resource "google_container_node_pool" "himem-node-pool" {
  name       = "himem-node-pool"
  location   = "us-east1-b"
  cluster    = module.stage-gke-cluster.gke-cluster-name
  node_count = 3

  node_config {
    preemptible     = false
    machine_type    = "n2-highmem-4"
    image_type      = "COS_CONTAINERD"
    ephemeral_storage_local_ssd_config {    
      local_ssd_count = 1
    }
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_project_iam_member" "default_compute_sm_read" {
  project = data.google_project.current.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = data.google_compute_default_service_account.default_compute.member
}


##### Temporary cluster set up due to issue with main stage cluster
##### Offers opportunity to test new machine type (c4a)

# module "genegraph-stage-cluster" {
#   source                    = "github.com/broadinstitute/tgg-terraform-modules//imported-gke-cluster?ref=1679ea8bb0fedfb879bca581624c6c51df6efbfa"
#   cluster_name             = "genegraph-stage-cluster"
#   cluster_location         = "us-east1-b"
#   network_id               = "projects/clingen-stage/global/networks/default"
#   subnetwork_id            = "projects/clingen-stage/regions/us-east1/subnetworks/default"
#   maint_start_time         = "2021-03-24T11:00:00Z"
#   maint_end_time           = "2021-03-24T23:00:00Z"
#   maint_recurrence_sched   = "FREQ=WEEKLY;BYDAY=SA,SU"
#   initial_node_count       = 1
#   remove_default_node_pool = true
#   cluster_v4_cidr          = "10.60.0.0/14"
#   services_v4_cidr         = "10.0.32.0/20"
#   resource_labels = {
#     admin      = "tristan"
#     creator    = "tristan"
#     managed_by = "terraform"
#   }
# }

resource "google_container_node_pool" "genegraph-stage-node-pool" {
  name       = "arm-ssd-node-pool"
  location   = "us-east1-b"
  cluster    = module.stage-gke-cluster.gke-cluster-name
  node_count = 1
  node_config {
    preemptible     = false
    machine_type    = "c4a-highmem-4-lssd"
    image_type      = "COS_CONTAINERD"
    ### https://cloud.google.com/compute/docs/general-purpose-machines#c4a_machine_types
    ### Should automatically configure one local ssd
    # ephemeral_storage_local_ssd_config {    
    #   local_ssd_count = 1
    # }
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
