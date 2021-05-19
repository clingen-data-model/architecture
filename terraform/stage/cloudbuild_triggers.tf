# clinvar-submitter build
resource "google_cloudbuild_trigger" "clinvar_submitter_push" {
  name        = "clinvar-submitter-stage-build"
  description = "Build clinvar submitter on push to master"

  github {
    name  = "clinvar-submitter"
    owner = "clingen-data-model"
    push {
      branch = "^master$"
    }
  }

  filename = "cloudbuild.yaml"
}

# architecture helm chart linting
resource "google_cloudbuild_trigger" "architecture_helm_lint" {
  name        = "architecture-helm-pr-lint"
  description = "lint helm charts in architecture when they've changed"

  github {
    name  = "architecture"
    owner = "clingen-data-model"
    pull_request {
      branch = "^master$"
    }
  }

  included_files = [
    "helm/**"
  ]

  filename = "helm/cloudbuild.yaml"
}
