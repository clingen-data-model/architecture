variable "remove_default_node_pool" {
  type    = boolean
  default = false
}

variable "maint_recurring_windows" {
  type    = list(map(object({ start_time = string, end_time = string, recurrence = string })))
  default = []
}

variable "maint_daily_windows" {
  type    = list(map(object({ start_time = string })))
  default = []
}

variable "maint_exclusions" {
  type    = list(map(object({ name = string, start_time = string, end_time = string })))
  default = []
}

variable "network_id" {
  type = string
}

variable "subnetwork_id" {
  type = string
}

variable "default_max_pods_per_node" {
  type = int
  default = 110
}

variable "enable_intranode_visibility" {
  type = boolean
  default = false
}

variable "enable_shielded_nodes" {
  type = boolean
  default = false
}

variable "enable_tpu" {
  type = boolean
  default = false
}
