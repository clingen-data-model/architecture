provider "google" {
  region  = "us-east1"
  project = "clingen-dx"
}

resource "google_service_account" "mondo_notifier_func" {
  account_id   = "clingen-mondo-notify"
  display_name = "Cloud function for notifying on new mondo releases"
}

resource "google_service_account" "confluent_cloud_pubsub_subscriber" {
  account_id   = "clingen-dev-mondo-subscriber"
  display_name = "Subscriber account for consuming mondo update notifications"
}

resource "google_pubsub_subscription_iam_member" "confluent_dev_binding" {
  subscription = google_pubsub_subscription.kafka_source_subscription.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.confluent_cloud_pubsub_subscriber.email}"
}

resource "google_pubsub_topic" "mondo_notifications" {
  name = "mondo-release-notifications"

  labels = {
    managed_by   = "terraform"
    owner        = "sjahl"
    pubsub_topic = "mondo-release-notifications"
  }
}

resource "google_pubsub_subscription" "kafka_source_subscription" {
  name  = "confluent-dev-cluster-source-subscription"
  topic = google_pubsub_topic.mondo_notifications.name

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering = false
}

resource "google_pubsub_topic_iam_member" "mondo_function" {
  topic  = google_pubsub_topic.mondo_notifications.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.mondo_notifier_func.email}"
}

# allows for automated cloudbuild deployments
resource "google_service_account_iam_member" "cloudbuild_mondo_notifier_binding" {
  service_account_id = "projects/clingen-dx/serviceAccounts/${google_service_account.mondo_notifier_func.email}"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:974091131481@cloudbuild.gserviceaccount.com"
}

resource "google_cloudbuild_trigger" "mondo_notifier_repo" {
  name        = "mondo-notifier-push"
  description = "Redeploy mondo notifier function on push to main"

  github {
    name  = "mondo-notifier"
    owner = "clingen-data-model"
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}
