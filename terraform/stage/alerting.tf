# notification targets
resource "google_monitoring_notification_channel" "clingen_private_alerts" {
  display_name = "clingen alerts for developer consumption"
  type         = "slack"
  labels = {
    "channel_name" = "#clingen-monitoring"
  }

  # what do we do here....
  # TODO: can this be a filled in with the content of a secret?
  sensitive_labels {
    auth_token = "i want this to be stored in a GCP secret"
  }
}

# alert policies 
resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "Genegraph Errors Policy"
  conditions {
    display_name = "test condition"
    condition_threshold {
      # TODO: how do we reference our custom metric in this filter?
      # TODO: do we need to define a threshold for this measurement?
      filter     = "metric.type=\"projects/clingen-stage/genegraph/metrics/errors_count\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

