resource "google_compute_global_address" "argocd_external_ip" {
  name = "global-dev-argocd-ip"
}

resource "google_dns_record_set" "argo_a_record" {
  name = "argocd-dev.${data.google_dns_managed_zone.clingen_dns_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.clingen_dns_zone.name

  rrdatas = [google_compute_global_address.argocd_external_ip.address]
}

module "broad_cloudarmor_policy" {
  source = "git@github.com:broadinstitute/terraform-shared.git//terraform-modules/cloud-armor-rule?ref=71303ce4f7d1249657ebe404059b0aea52523748"
}
