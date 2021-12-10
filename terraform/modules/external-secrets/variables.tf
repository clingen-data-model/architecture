variable "env" {
  type        = string
  description = "The name of the environment we are deploying to. E.g. {dev,stage,prod}"
}

variable "project_id" {
  type = string
  description = "A string containing the name of the project to create IAM resources in. Required as of google provider version 4.0"
}
