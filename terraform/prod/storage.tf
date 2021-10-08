data "google_service_account" "clingen_stage_default_compute_sa" {
  account_id = "583560269534-compute@developer.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "gengeraph_stage" {
  bucket = "genegraph-prod"
  role   = "roles/storage.admin"
  member = "serviceAccount:${data.google_service_account.clingen_stage_default_compute_sa.email}"
}
