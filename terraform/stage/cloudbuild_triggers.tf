resource "google_cloudbuild_trigger" "clinvar_submitter_push" {
  name = "clinvar-submitter-stage-build"
  description = "Build clinvar submitter on push to master"

  github {
    name   = "clinvar-submitter"
    owner       = "clingen-data-model"
    push {
        branch = "^master$"
    }
  }

  filename = "cloudbuild.yaml"
}
