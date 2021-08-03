####
# Notification Channels
####

data "google_secret_manager_secret_version" "slack_token" {
  secret  = "clingen-notification-slack-token"
  version = 1
}

resource "google_monitoring_notification_channel" "clingen_private_alerts" {
  display_name = "#clingen-monitoring channel: clingen alerts for developer consumption"
  type         = "slack"
  labels = {
    "channel_name" = "#clingen-monitoring"
  }

  sensitive_labels {
    auth_token = data.google_secret_manager_secret_version.slack_token.secret_data
  }
}

####
# Alert Policies
####

resource "google_monitoring_alert_policy" "kubernetes_pod_volume_utilization" {
  display_name = "kubernetes pod storage utilization alarm"
  combiner     = "OR"
  conditions {
    display_name = "pod storage volume utilization is greater than 80%"
    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/pod/volume/utilization\" resource.type=\"k8s_pod\""
      duration        = "600s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.8"
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["metric.label.\"volume_name\"", "resource.label.\"pod_name\""]
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.clingen_private_alerts.id
  ]
}
