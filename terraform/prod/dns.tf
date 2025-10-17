# prod.clingen.app dns zone
resource "google_dns_managed_zone" "clingen_prod_dns_zone" {
  name        = "prod-clingen-app-zone"
  dns_name    = "prod.clingen.app."
  description = "Managed by Terraform, Delegated from clingen.app zone in clingen-dev"
}

# upstream DNS zone records, for delegation
data "google_dns_managed_zone" "clingen_dev_dns_zone" {
  name    = "clingen-app"
  project = "clingen-dev"
}

# creates the delegated NS records in clingen-dev, since that's where the clingen.app domain zone lives
resource "google_dns_record_set" "clingen_prod_dns_zone_ns" {
  managed_zone = data.google_dns_managed_zone.clingen_dev_dns_zone.name
  project      = "clingen-dev"
  name         = "prod.clingen.app."
  type         = "NS"
  ttl          = 300
  rrdatas      = google_dns_managed_zone.clingen_prod_dns_zone.name_servers
}

# Reserved static IP addresses
resource "google_compute_global_address" "argocd_external_ip" {
  name = "global-prod-argocd-ip"
}

# DNS Records in the prod.clingen.app zone
resource "google_dns_record_set" "argo_a_record" {
  name = "argocd.${google_dns_managed_zone.clingen_prod_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_prod_dns_zone.name

  rrdatas = [google_compute_global_address.argocd_external_ip.address]
}

# Reserved static IP addresses
resource "google_compute_global_address" "clinvar_submitter_ip" {
  name = "global-prod-clinvar-submitter-ip"
}

# DNS Records in the prod.clingen.app zone
resource "google_dns_record_set" "clinvar_submitter_a_record" {
  name = "clinvar-submitter.${google_dns_managed_zone.clingen_prod_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_prod_dns_zone.name

  rrdatas = [google_compute_global_address.clinvar_submitter_ip.address]
}

resource "google_compute_global_address" "genegraph_prod_external_ip" {
  name = "global-prod-genegraph-prod-ip"
}

resource "google_compute_global_address" "genegraph_gene_validity_prod_external_ip" {
  name = "global-prod-genegraph-gene-validity-prod-ip"
}

# DNS Records in the prod.clingen.app zone
resource "google_dns_record_set" "genegraph_prod_a_record" {
  name = "genegraph.${google_dns_managed_zone.clingen_prod_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_prod_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_prod_external_ip.address]
}

resource "google_dns_record_set" "genegraph_gene_validity_prod_a_record" {
  name = "genegraph-gene-validity.${google_dns_managed_zone.clingen_prod_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_prod_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_gene_validity_prod_external_ip.address]
}

resource "google_compute_global_address" "genegraph_api_prod_external_ip" {
  name = "global-prod-genegraph-api-ip"
}

resource "google_dns_record_set" "genegraph_api_prod_a_record" {
  name = "genegraph-api.${google_dns_managed_zone.clingen_prod_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_prod_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_api_prod_external_ip.address]
}

resource "google_compute_global_address" "genegraph_legacy_test_external_ip" {
  name = "global-genegraph-legacy-test-ip"
}

resource "google_dns_record_set" "genegraph_legacy_test_prod_a_record" {
  name = "genegraph-legacy-test.${google_dns_managed_zone.clingen_prod_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_prod_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_legacy_test_external_ip.address]
}

resource "google_compute_global_address" "genegraph_legacy_external_ip" {
  name = "global-genegraph-legacy-ip"
}

resource "google_dns_record_set" "genegraph_legacy_prod_a_record" {
  name = "genegraph-legacy.${google_dns_managed_zone.clingen_prod_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.clingen_prod_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_legacy_external_ip.address]
}
