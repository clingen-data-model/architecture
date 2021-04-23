resource "google_cloudbuild_trigger" "clinvar_submitter_push" {
  github {
    name   = "clinvar-submitter"
    owner       = "clingen-data-model"
    push {
        branch = "^master$"
    }
  }

  filename = "cloudbuild.yaml"
}
