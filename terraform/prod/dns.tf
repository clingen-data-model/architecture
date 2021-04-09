resource "google_dns_managed_zone" "clingen_prod_zone" {
  name = "prod-clingen-app-zone"
  dns_name = "prod.clingen.app."
  description = "Managed by Terraform, Delegated from clingen.app zone in clingen-dev"
}

# resource "google_compute_global_address" "argocd_external_ip" {
#   name = "global-prod-argocd-ip"
# }

# resource "google_dns_record_set" "argo_a_record" {
#   name = "argocd.${google_dns_managed_zone.clingen_dns_zone.dns_name}"
#   project = "clingen-dev"
#   type = "A"
#   ttl  = 300

#   managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name

#   rrdatas = [google_compute_global_address.argocd_external_ip.address]
# }

