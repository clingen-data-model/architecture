provider "google" {
  project = "clingen-dx"
  region  = "us-east1"
}

module "external-secrets" {
  source = "../modules/external-secrets"
  env    = "prod"
}
