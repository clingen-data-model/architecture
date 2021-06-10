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