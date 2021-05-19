resource "google_logging_metric" "genegraph_errors" {
  name   = "projects/clingen-stage/genegraph/metrics/errors_count"
  filter = <<-EOT
        labels."k8s-pod/app" AND severity>=WARNING"
    EOT
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    labels {
      key         = "logName"
      value_type  = "STRING"
      description = "Name of the logfile"
    }
  }
  label_extractors = {
    "logName" = "EXTRACT(jsonPayload.logName)"
  }
}

