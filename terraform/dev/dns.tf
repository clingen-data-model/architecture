resource "google_compute_global_address" "argocd_external_ip" {
  name = "global-dev-argocd-ip"
}

# NOT managed, just referenecd
data "google_dns_managed_zone" "clingen_dns_zone" {
  name = "clingen-app"
}

resource "google_dns_record_set" "argo_a_record" {
  name = "argocd-dev.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name

  rrdatas = [google_compute_global_address.argocd_external_ip.address]
}

# delegated sub zones
data "google_dns_managed_zone" "prod_clingen_dns_zone" {
  name = "prod-clingen-app-zone"
  project = "clingen-dx"
}

resource "google_dns_record_set" "clingen_prod_dns_zone_ns" {
  managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name
  name    = "prod.clingen.app."
  type    = "NS"
  ttl     = 300
  rrdatas = data.google_dns_managed_zone.prod_clingen_dns_zone.name_servers
 }
