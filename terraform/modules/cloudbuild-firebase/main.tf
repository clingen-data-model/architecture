# Grant the firebase roles to the cloudbuild serviceaccount
resource "google_project_iam_member" "cloudbuild_firebase_binding" {
  role    = "roles/firebase.admin"
  member  = "serviceAccount:${var.project_id_number}@cloudbuild.gserviceaccount.com"
  project = var.project_id
}

resource "google_project_iam_member" "cloudbuild_apikeys_binding" {
  role    = "roles/serviceusage.apiKeysAdmin"
  member  = "serviceAccount:${var.project_id_number}@cloudbuild.gserviceaccount.com"
  project = var.project_id
}
