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
      project_id = "clingen-dx"
      host       = "clinvar-submitter.clinicalgenome.org"
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
      project_id = "clingen-dx"
      host       = "34.75.154.128" # TODO: see if this hostname is defined in tf
    }
  }

  content_matchers {
    content = "server is ready"
    matcher = "CONTAINS_STRING"
  }
}
