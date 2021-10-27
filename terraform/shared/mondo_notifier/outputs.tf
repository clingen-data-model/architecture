output "mondo_notifier_service_account" {
  value = google_service_account.mondo_notifier_func.email
}
