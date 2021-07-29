####
# Custom Log-based Metrics, appearing at https://console.cloud.google.com/logs/metrics
###

resource "google_logging_metric" "data-exchange-migration-debug" {
  filter = <<-EOT
	resource.type="k8s_container"
	resource.labels.project_id="clingen-dx"
	resource.labels.location="us-east1-b"
	resource.labels.cluster_name="prod-cluster"
	resource.labels.namespace_name="default"
	labels.k8s-pod/app="data-exchange-migration"
	textPayload=~".* DEBUG .*"
  EOT

  name = "data-exchange-migration_debug"

  metric_descriptor {
    metric_kind = "DELTA"
    unit        = "1"
    value_type  = "INT64"
  }
}
