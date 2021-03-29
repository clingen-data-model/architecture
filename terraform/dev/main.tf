provider "google" {
  project = "clingen-dev"
  region  = "us-east1"
}

# The IAM role that we'll use to allow read access to all GCP secrets within the project
resource "google_project_iam_custom_role" "external-secrets-gsa" {
  role_id     = "clingen_dev_external_secrets"
  title       = "Clingen Dev Secret Manager Read Access"
  description = "intended to allow the external-secrets controller to access secrets"
  permissions = [
    "resourcemanager.projects.get",
    "secretmanager.locations.get",
    "secretmanager.locations.list",
    "secretmanager.secrets.get",
    "secretmanager.secrets.getIamPolicy",
    "secretmanager.secrets.list",
    "secretmanager.versions.get",
    "secretmanager.versions.list",
    "secretmanager.versions.access",
  ]
}

# The ServiceAccount that the external-secrets controller will use to identify itself to the GCP API.
resource "google_service_account" "clingen-dev-external-secrets" {
  account_id   = "clingen-dev-external-secrets"
  display_name = "Clingen Dev External Secrets Controller"
}

# Bind the ServiceAccount to the IAM role.
resource "google_project_iam_member" "k8s-external-secrets-iam-membership" {
  role   = google_project_iam_custom_role.external-secrets-gsa.name
  member = "serviceAccount:${google_service_account.clingen-dev-external-secrets.email}"
}

# Generate a key for the ServiceAccount, for the controller to authenticate with
resource "google_service_account_key" "external_secrets_sa_key" {
  service_account_id = google_service_account.clingen-dev-external-secrets.name
}

# create a secret to store the service account key in
resource "google_secret_manager_secret" "external_secrets_sa_key_secret" {
  secret_id = "secret"

  replication {
    automatic = true
  }
}

# store the actual key data as a secret version
resource "google_secret_manager_secret_version" "external_secrets_key_version" {
  secret = google_secret_manager_secret.external_secrets_sa_key_secret.id

  secret_data = base64decode(google_service_account_key.external_secrets_sa_key.private_key)
}
