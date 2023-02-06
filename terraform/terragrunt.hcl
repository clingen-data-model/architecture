terragrunt_version_constraint = "< 0.50"

generate "terraform" {
  path = "terraform_versioning.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_version = ">= 1.0.0, < 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.26.0"
    }
  }
}
EOF
}
