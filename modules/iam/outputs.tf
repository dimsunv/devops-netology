output "id" {
  value       = "${yandex_iam_service_account.resource.id}"
  description = "id_resource"
}
output "access_key" {
  value = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
  sensitive = true
}
output "secret_key" {
  value = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
  sensitive = true
}
