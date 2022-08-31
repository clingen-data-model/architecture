resource "google_storage_bucket" "ga4gh_cvc_metakb" {
  name          = "ga4gh-cvc-metakb"
  storage_class = "STANDARD"
  location      = "us-east1"
}
