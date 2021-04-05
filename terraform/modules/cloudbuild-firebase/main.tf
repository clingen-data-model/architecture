data "google_service_account" "cloudbuild_default_serviceaccount" {
  account_id = "${var.project_id_number}@cloudbuild.gserviceaccount.com"
}

data "google_iam_role" "firebase_admin_role" {
  name = "roles/firebase.admin"
}

data "google_iam_role" "api_keys_admin_role" {
  name = "roles/serviceusage.apiKeysAdmin"
}

# Grant the firebase roles to the cloudbuild serviceaccount
resource "google_project_iam_member" "cloudbuild_firebase_binding" {
  role   = google_project_iam_role.firebase_admin_role.name
  member = "serviceAccount:${google_service_account.cloudbuild_default_serviceaccount.email}"
}

resource "google_project_iam_member" "cloudbuild_apikeys_binding" {
  role   = google_project_iam_role.api_keys_admin_role.name
  member = "serviceAccount:${google_service_account.cloudbuild_default_serviceaccount.email}"
}
