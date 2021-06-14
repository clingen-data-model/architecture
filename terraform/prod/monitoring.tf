####
# Notification Channels
####

data "google_secret_manager_secret_version" "slack_token" {
  secret  = "clingen-notification-slack-token"
  version = 1
}

resource "google_monitoring_notification_channel" "clingen_private_alerts" {
  display_name = "clingen alerts for developer consumption"
  type         = "slack"
  labels = {
    "channel_name" = "#clingen-monitoring"
  }

  sensitive_labels {
    auth_token = data.google_secret_manager_secret_version.slack_token.secret_data
  }
}

####
# Uptime Checks
####

resource "google_monitoring_uptime_check_config" "clinvar_submitter_website" {
  display_name = "clinvar-submitter-website"
  timeout      = "10s"

  http_check {
    path           = "/api/v1/submission?healthcheck"
    port           = "80"
    request_method = "GET"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      host = "clinvar-submitter.clinicalgenome.org"
    }
  }
}

resource "google_monitoring_uptime_check_config" "genegraph_prod" {
  display_name = "genegraph-prod"
  timeout      = "60s"

  http_check {
    path           = "/ready"
    port           = "80"
    request_method = "GET"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      host = "34.75.154.128"
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
