####
# Cloud Logging configuration for the clingen-dev project
###

resource "google_logging_project_bucket_config" "default" {
  project        = data.google_project.current.id
  location       = "global"
  bucket_id      = "_Default"
  retention_days = 365
}
