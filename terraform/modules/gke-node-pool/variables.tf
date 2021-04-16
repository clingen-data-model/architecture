variable "node_pool_name" {
    type = string
}

variable "node_pool_location" {
    type = string
    description = "the GCP region where this node pool lives"
}

variable "container_cluster_name" {
    type = string
    description = "The .name value of the container cluster"
}

variable "node_count" {
    type = int
    default = 1
    description = "The number of nodes to include in the pool"
}

variable "preemptible" {
    type = boolean
    default = false
    description = "Whether or not nodes should be preemptible"
}

variable "machine_type" {
    type = string
    description = "the GCP instance size/type for the nodes in the pool"
}
