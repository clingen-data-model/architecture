# trigger for the prod ClinvarSCV cloudfunction deployment
resource "google_cloudbuild_trigger" "clinvar_scv_prod" {
  name        = "ClinVarSCVChange"
  description = "Redeploy ClinVarSCV Cloud Function Trigger"
  disabled    = true

  github {
    name  = "clinvar-submitter"
    owner = "clingen-data-model"
    pull_request {
      branch = "^master$"
    }
  }

  included_files = [
    "gcp/function-source/*"
  ]
}
