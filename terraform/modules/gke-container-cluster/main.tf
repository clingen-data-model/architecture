resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.cluster_location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = 1

  maintenance_policy {
    dynamic "recurring_window" {
      for_each = var.maint_recurring_windows
      content {
        start_time = each.value.start_time
        end_time   = each.value.end_time
        recurrence = each.value.recurrence
      }
    }

    dynamic "daily_maintenance_window" {
      for_each = var.maint_daily_windows
      content {
        start_time = each.value.start_time
      }
    }

    dynamic "maintenance_exclusion" {
      for_each = var.maint_exclusions
      content {
        exclusion_name = each.value.name
        start_time     = each.value.start_time
        end_time       = each.value.end_time
      }
    }

  }
}
