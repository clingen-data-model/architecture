# Clingen.app dns zone
# NOT managed, just referenecd
data "google_dns_managed_zone" "clingen_dns_zone" {
  name = "clingen-app"
}

# static IP reservations

# resource "google_compute_global_address" "genegraph_dev_external_ip" {
#   name = "global-dev-genegraph-dev-ip"
# }

# resource "google_compute_global_address" "anyvar_dev_external_ip" {
#   name = "global-anyvar-dev-ip"
# }

# DNS records

# resource "google_dns_record_set" "genegraph_dev_a_record" {
#   name = "genegraph-dev.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
#   type = "A"
#   ttl  = 300
#   managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name
#   rrdatas = [google_compute_global_address.genegraph_dev_external_ip.address]
# }

# resource "google_dns_record_set" "anyvar_dev_a_record" {
#   name = "anyvar-dev.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
#   type = "A"
#   ttl  = 300
#   managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name
#   rrdatas = [google_compute_global_address.anyvar_dev_external_ip.address]
# }
