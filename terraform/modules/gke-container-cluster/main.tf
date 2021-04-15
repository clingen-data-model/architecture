resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.cluster_location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  if var.enable_maintenance_policy {
    maintenance_policy {
      recurring_window {
        # start_time = "2021-03-24T11:00:00Z"
        start_time = var.maint_start_timespec
        # end_time   = "2021-03-24T23:00:00Z"
        end_time   = var.maint_end_timespec
        # recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
        recurrence = var.maint_recurrence_spec
      }
    }
  }
}

