module "clingen_projects_iam_bindings" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "7.2.0"

  projects = ["clingen-dx", "clingen-stage", "clingen-dev"]

  bindings = {
    "roles/storage.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/container.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/compute.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/appengine.appCreator" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/appengine.appAdmin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/cloudfunctions.admin" = [
      "group:clingendevs@broadinstitute.org"
    ]

    "roles/run.admin" = [
      "group:clingendevs@broadinstitute.org"
    ]

    "roles/cloudscheduler.admin" = [
      "group:clingendevs@broadinstitute.org"
    ]

    "roles/dns.admin" = [
      "group:clingendevs@broadinstitute.org"
    ]

    "roles/bigquery.admin" = [
      "group:clingendevs@broadinstitute.org"
    ]

    "roles/monitoring.admin" = [
      "group:clingendevs@broadinstitute.org"
    ]

    "roles/pubsub.admin" = [
      "group:clingendevs@broadinstitute.org"
    ]

    "roles/firebase.admin" = [
      "group:clingendevs@broadinstitute.org"
    ]

    "roles/cloudbuild.builds.editor" = [
      "group:clingendevs@broadinstitute.org"
    ]

    "roles/billing.viewer" = [
      "group:clingendevs@broadinstitute.org"
    ]
  }
}
