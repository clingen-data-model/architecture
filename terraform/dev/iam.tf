# project-level permissions that need to be consistent across all three environments
module "clingen_projects_iam_bindings" {
  source  = "terraform-google-modules/iam/google//modules/projects_iam"
  version = "7.2.0"
  mode    = "additive"

  projects = ["clingen-dx", "clingen-stage", "clingen-dev"]

  bindings = {
    "roles/storage.admin" = [
      "group:clingendevs@broadinstitute.org",
      "group:<collaborators-tbd>@broadinstitute.org",
    ]

    "roles/container.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/compute.admin" = [
      "group:clingendevs@broadinstitute.org",
      "group:<collaborators-tbd>@broadinstitute.org",
    ]

    "roles/appengine.appCreator" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/appengine.appAdmin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/cloudfunctions.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/run.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/cloudscheduler.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/dns.admin" = [
      "group:clingendevs@broadinstitute.org",
      "group:<collaborators-tbd>@broadinstitute.org",

    ]

    "roles/bigquery.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/monitoring.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/pubsub.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/firebase.admin" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/cloudbuild.builds.editor" = [
      "group:clingendevs@broadinstitute.org",
    ]

    "roles/billing.viewer" = [
      "group:clingendevs@broadinstitute.org",
    ]
  }
}

# grants read access for specific storage buckets
module "clingen_storage_readers_iam" {
  source  = "terraform-google-modules/iam/google//modules/storage_buckets_iam"
  version = "7.2.0"
  mode    = "additive"

  storage_buckets = ["clinvar-reports"]

  bindings = {
    "roles/storage.objectViewer" = [
      "<clingen-data-viewers-tbd>@broadinstitute.org",
    ]
  }
}
