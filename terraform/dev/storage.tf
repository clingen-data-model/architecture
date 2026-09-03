####
# GCS buckets for the clingen-dev project
###

# Holds the clinvar-ingest pipeline's staged XML, parsed NDJSON, and per-execution output.
resource "google_storage_bucket" "clinvar_ingest_dev" {
  name     = "clinvar-ingest-dev"
  location = "US"

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  soft_delete_policy {
    retention_duration_seconds = 7776000 # 90 days, the maximum
  }
}
