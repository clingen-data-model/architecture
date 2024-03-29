# Clingen.app dns zone
# NOT managed, just referenecd
data "google_dns_managed_zone" "clingen_dns_zone" {
  name = "clingen-app"
}

# static IP reservations
resource "google_compute_global_address" "genegraph_gvdev_external_ip" {
  name = "global-dev-genegraph-gvdev-ip"
}

resource "google_compute_global_address" "genegraph_dev_external_ip" {
  name = "global-dev-genegraph-dev-ip"
}

resource "google_compute_global_address" "genegraph_dev_clinvar_external_ip" {
  name = "global-dev-genegraph-clinvar-ip"
}

resource "google_compute_global_address" "anyvar_dev_external_ip" {
  name = "global-anyvar-dev-ip"
}

resource "google_compute_global_address" "genegraph_gene_validity_dev_external_ip" {
  name = "global-dev-genegraph-gene-validity-ip"
}


# DNS records
resource "google_dns_record_set" "genegraph_gvdev_a_record" {
  name = "genegraph-gvdev.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_gvdev_external_ip.address]
}

resource "google_dns_record_set" "genegraph_gene_validity_dev_a_record" {
  name = "genegraph-gene-validity-dev.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_gene_validity_dev_external_ip.address]
}

resource "google_dns_record_set" "genegraph_dev_a_record" {
  name = "genegraph-dev.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_dev_external_ip.address]
}

resource "google_dns_record_set" "genegraph_dev_clinvar_a_record" {
  name = "genegraph-dev-clinvar.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_dev_clinvar_external_ip.address]
}

resource "google_dns_record_set" "genegraph_testing_a_record" {
  name = "genegraph-testing.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name

  rrdatas = [google_compute_global_address.genegraph_dev_external_ip.address]
}

resource "google_dns_record_set" "anyvar_dev_a_record" {
  name = "anyvar-dev.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name

  rrdatas = [google_compute_global_address.anyvar_dev_external_ip.address]
}

# Variation normalizer (prod)
resource "google_compute_global_address" "variation_normalizer_ip" {
  name = "global-variation-normalizer-ip"
}

resource "google_dns_record_set" "variation_normalization_a_record" {
  name = "normalization.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
  type = "A"
  ttl  = 300
  managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name
  rrdatas = [google_compute_global_address.variation_normalizer_ip.address]
}

# Variation normalizer (dev)
resource "google_compute_global_address" "variation_normalizer_dev_ip" {
  name = "global-variation-normalizer-dev-ip"
}

resource "google_dns_record_set" "variation_normalization_dev_a_record" {
  name = "normalization-dev.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
  type = "A"
  ttl  = 300
  managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name
  rrdatas = [google_compute_global_address.variation_normalizer_dev_ip.address]
}
