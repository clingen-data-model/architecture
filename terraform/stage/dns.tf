# stage.clingen.app dns zone
resource "google_dns_managed_zone" "clingen_stage_dns_zone" {
  name        = "stage-clingen-app-zone"
  dns_name    = "stage.clingen.app."
  description = "Managed by Terraform, Delegated from clingen.app zone in clingen-dev"
}

# upstream DNS zone records, for delegation
data "google_dns_managed_zone" "clingen_dev_dns_zone" {
  name    = "clingen-app"
  project = "clingen-dev"
}

# creates the delegated NS records in clingen-dev, since that's where the clingen.app domain zone lives
resource "google_dns_record_set" "clingen_stage_dns_zone_ns" {
  managed_zone = data.google_dns_managed_zone.clingen_dev_dns_zone.name
  project      = "clingen-dev"
  name         = "stage.clingen.app."
  type         = "NS"
  ttl          = 300
  rrdatas      = google_dns_managed_zone.clingen_stage_dns_zone.name_servers
}

# Reserved static IP addresses
resource "google_compute_global_address" "clinvar_submitter_ip" {
  name = "global-stage-clinvar-submitter-ip"
}

resource "google_compute_global_address" "genegraph_stage_external_ip" {
  name = "clingen-ds-stage-ip"
}

resource "google_compute_global_address" "genegraph_stage_clinvar_external_ip" {
  name = "clingen-genegraph-stage-clinvar-ip"
}

resource "google_compute_global_address" "genegraph_gene_validity_stage_external_ip" {
  name = "global-stage-genegraph-gene-validity-ip"
}

resource "google_compute_global_address" "genegraph_api_stage_external_ip" {
  name = "global-stage-genegraph-api-ip"
}

# DNS Records in the stage.clingen.app zone
resource "google_dns_record_set" "clinvar_submitter_a_record" {
  name = "clinvar-submitter.${google_dns_managed_zone.clingen_stage_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_stage_dns_zone.name

  rrdatas = [google_compute_global_address.clinvar_submitter_ip.address]
}

resource "google_dns_record_set" "genegraph_stage_a_record" {
  name = "genegraph.${google_dns_managed_zone.clingen_stage_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_stage_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_stage_external_ip.address]
}

resource "google_dns_record_set" "genegraph_stage_clinvar_a_record" {
  name = "genegraph-clinvar.${google_dns_managed_zone.clingen_stage_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_stage_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_stage_clinvar_external_ip.address]
}

resource "google_dns_record_set" "genegraph_gene_validity_stage_a_record" {
  name = "genegraph-gene-validity.${google_dns_managed_zone.clingen_stage_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_stage_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_gene_validity_stage_external_ip.address]
}


resource "google_dns_record_set" "genegraph_api_stage_a_record" {
  name = "genegraph-api.${google_dns_managed_zone.clingen_stage_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_stage_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_api_stage_external_ip.address]
}


# Genegraph Gene Validity Dev instance

resource "google_compute_global_address" "genegraph_gene_validity_stage_dev_external_ip" {
  name = "global-stage-dev-genegraph-gene-validity-ip"
}

resource "google_dns_record_set" "genegraph_gene_validity_stage_dev_a_record" {
  name = "genegraph-gene-validity-dev.${google_dns_managed_zone.clingen_stage_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_stage_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_gene_validity_stage_dev_external_ip.address]
}
