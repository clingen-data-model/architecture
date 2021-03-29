provider "google" {
  project = "clingen-dev"
  region  = "us-east1"
}

module "external-secrets" {
  source = "../modules/external-secrets"
  env    = "dev"
}
