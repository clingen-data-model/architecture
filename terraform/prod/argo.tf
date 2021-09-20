module "broad_cloudarmor_policy" {
  source = "github.com/broadinstitute/terraform-shared//terraform-modules/cloud-armor-rule?ref=71303ce4f7d1249657ebe404059b0aea52523748"
}


resource "google_compute_security_policy" "argocd_cloudarmor_policy" {
  name = "clingen-argo-cloud-armor"

  # only 5 cidrs allowed per rule
  rule {
    action   = "allow"
    priority = "0"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = [
          "69.173.112.0/21",
          "69.173.127.232/29",
          "69.173.127.128/26",
          "69.173.127.0/25",
          "69.173.127.240/28"
        ]
      }
    }
  }
  # only 5 cidrs allowed per rule
  rule {
    action   = "allow"
    priority = "1"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = [
          "69.173.127.224/30",
          "69.173.127.230/31",
          "69.173.120.0/22",
          "69.173.127.228/32",
          "69.173.126.0/24"
        ]
      }
    }
  }
  # only 5 cidrs allowed per rule
  rule {
    action   = "allow"
    priority = "2"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = [
          "69.173.96.0/20",
          "69.173.64.0/19",
          "69.173.127.192/27",
          "69.173.124.0/23"
        ]
      }
    }
  }

  rule {
    action      = "deny(403)"
    priority    = "2147483647"
    description = "Default rule: deny all"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}
