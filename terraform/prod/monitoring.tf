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

resource "google_monitoring_notification_channel" "clingen_public_alerts" {
  display_name = "#clingen-alerts channel: clingen alerts for public and user consumption"
  type         = "slack"
  labels = {
    "channel_name" = "#clingen-alerts"
  }

  sensitive_labels {
    auth_token = data.google_secret_manager_secret_version.slack_token.secret_data
  }
}

####
# Uptime Checks
####

resource "google_monitoring_uptime_check_config" "clinvar_submitter_website" {
  display_name = "Clinvar Submitter Web Site"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path           = "/api/v1/submission?healthcheck"
    port           = "80"
    request_method = "GET"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = "clinvar-submitter.clinicalgenome.org"
      project_id = "clingen-dx"
    }
  }
}

resource "google_monitoring_uptime_check_config" "genegraph_prod_tls" {
  display_name = "genegraph.prod.clingen.app"
  timeout      = "60s"
  period       = "60s"

  http_check {
    path           = "/ready"
    port           = "443"
    request_method = "GET"
    use_ssl        = true
    validate_ssl   = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = "genegraph.prod.clingen.app"
      project_id = "clingen-dx"
    }
  }

  content_matchers {
    content = "server is ready"
    matcher = "CONTAINS_STRING"
  }
}

####
# Alert Policies
####

resource "google_monitoring_alert_policy" "genegraph_prod_mem_util_alert_policy" {
  display_name = "genegraph memory limit utilization"
  combiner     = "OR"
  conditions {
    display_name = "memory limit utilization is greater than 80%"
    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/container/memory/limit_utilization\" resource.type=\"k8s_container\" resource.label.\"cluster_name\"=\"prod-cluster\" resource.label.\"container_name\"=\"genegraph\" metric.label.\"memory_type\"=\"non-evictable\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.8"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.clingen_private_alerts.id
  ]
}

resource "google_monitoring_alert_policy" "prod_node_allocatable_memory_utilization" {
  display_name = "Prod node memory utilization"
  combiner     = "OR"
  conditions {
    display_name = "node memory is more than 75% allocated"
    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/node/memory/allocatable_utilization\" resource.type=\"k8s_node\" resource.label.\"cluster_name\"=\"prod-cluster\" metric.label.\"memory_type\"=\"non-evictable\""
      duration        = "1800s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.75"
      aggregations {
        alignment_period   = "360s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.clingen_private_alerts.id
  ]
}

resource "google_monitoring_alert_policy" "kubernetes_pod_volume_utilization" {
  display_name = "kubernetes pod volume utilization alarm"
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

# TODO: Google doesn't allow us to manage GCP mobile apps as notification targets via the API (they are console-only)
# the current alerting policies use the GCP mobile apps as targets. Need to speak with the team to get their thoughts
# on how well that works, and if we should consider alternatives

# resource "google_monitoring_alert_policy" "clinvar_submitter_check" {
#   enabled      = true
#   display_name = "Uptime Health Check on Clinvar Submitter Web Site"

#   documentation {
#     content   = <<-EOT
#     Stackdriver Monitoring Service Alert!!!

# 	The ClinVarSubmitter website has been unreachable for 5 minutes. 

# 	To manually test the service go to this URL via a web browser: 

# 	http://clinvar-submitter.clinicalgenome.org/api/v1/submission?healthcheck

# 	You should receive the following on the screen:

# 	{"status":{"totalRecords":0,"successCount":0,"errorCount":0},"variants":[]}

# 	To disable this alerting policy, go to this URL:

# 	https://app.google.stackdriver.com/policies?project=clingen-dx

# 	and disable the "Clinvar Submitter Website Policy."
# 	EOT
#     mime_type = "text/markdown"
#   }

#   conditions {
#     display_name = "Uptime Checks Failed"

#     condition_threshold {
#       duration = "300s"
#       filter   = <<-EOT
#         metric.type="monitoring.googleapis.com/uptime_check/check_passed"
#         resource.type="uptime_url"
#         metric.label."check_id"="${google_monitoring_uptime_check_config.clinvar_submitter_website.uptime_check_id}"
#       EOT

#       comparison      = "COMPARISON_GT"
#       threshold_value = 1

#       aggregations {
#         alignment_period     = "1200s"
#         cross_series_reducer = "REDUCE_COUNT_FALSE"
#         group_by_fields      = ["resource.*"]
#         per_series_aligner   = "ALIGN_NEXT_OLDER"
#       }

#       trigger {
#         count = 1
#       }

#     }
#   }

#   combiner = "OR"

#   notification_channels = [
#     google_monitoring_notification_channel.clingen_private_alerts.id
#   ]
# }

# resource "google_monitoring_alert_policy" "genegraph_prod_check" {
#   enabled      = true
#   display_name = "Failure of uptime check_id genegraph-prod"

#   documentation {
#     content   = "The production deployment of Genegraph has failed to respond to an automated, periodic query, indicating that the application may have failed. "
#     mime_type = "text/markdown"
#   }


#   conditions {
#     display_name = "Uptime Checks Failed"

#     condition_threshold {
#       duration = "60s"
#       filter   = <<-EOT
#         metric.type="monitoring.googleapis.com/uptime_check/check_passed"
#         resource.type="uptime_url"
#         metric.label."check_id"="${google_monitoring_uptime_check_config.genegraph_prod.uptime_check_id}"
#       EOT

#       comparison      = "COMPARISON_GT"
#       threshold_value = 1

#       aggregations {
#         alignment_period     = "1200s"
#         cross_series_reducer = "REDUCE_COUNT_FALSE"
#         group_by_fields      = ["resource.*"]
#         per_series_aligner   = "ALIGN_NEXT_OLDER"
#       }

#       trigger {
#         count = 1
#       }
#     }
#   }

#   combiner = "OR"

#   notification_channels = [
#     google_monitoring_notification_channel.clingen_private_alerts.id
#   ]
# }
