terragrunt_version_constraint = "< 0.37"

generate "terraform" {
  path = "terraform_versioning.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_version = ">= 1.0.0, < 1.2.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.3.0"
    }
  }
}
EOF
}
