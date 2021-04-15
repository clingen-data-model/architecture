variable "remove_default_node_pool" {
    type = boolean
    default = false
}

variable "maint_recurring_windows" {
  type = list(map(object({start_time = string, end_time = string, recurrence = string})))
}

variable "maint_daily_windows" {
    type = list(map(object({start_time = string})))
}

variable "maint_exclusions" {
    type = list(map(object({name = string, start_time = string, end_time = string})))
}
