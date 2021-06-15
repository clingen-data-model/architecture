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

# curator build
resource "google_cloudbuild_trigger" "curator_stage" {
  name        = "curator-stage-deploy"
  description = "triggers on push to curator/master"

  substitutions = {
    _GENEGRAPH_HOST = "https://clingen.app"
  }

  github {
    name  = "curator"
    owner = "clingen-data-model"
    push {
      branch = "^master$"
    }
  }

  filename = "cloudbuild.yaml"
}

# genegraph stage build
resource "google_cloudbuild_trigger" "genegraph_stage" {
  name        = "genegraph-stage-build"
  description = "Build Genegraph on push to master. Copy image to prod. Sync stage and prod migration buckets."

  github {
    name  = "genegraph"
    owner = "clingen-data-model"
    push {
      branch = "^master$"
    }
  }

  filename = "cloudbuild.yaml"
}

# # clinvar streams build
resource "google_cloudbuild_trigger" "clinvar_streams_build" {
  name        = "clinvar-streams-build"
  description = "Build clinvar-streams docker image on push to master"

  github {
    name  = "clinvar-streams"
    owner = "clingen-data-model"
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}
