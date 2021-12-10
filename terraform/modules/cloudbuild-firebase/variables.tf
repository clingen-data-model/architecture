variable "project_id_number" {
  type        = string
  description = "The project number prefix of the default service accounts."
}

variable "project_id" {
  type = string
  description = "The project ID to create the IAM resources in. Required as of google provider version 4.0"
}
