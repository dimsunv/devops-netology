
variable project_name { default = "" }
variable folder_id { default = "" }

resource "yandex_iam_service_account" "resource" {
  name        = "${var.project_name}-resource"
  folder_id   = "${var.folder_id}"
  description = "service account to manage bucket"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = "${var.folder_id}"
  role      = "storage.editor"
  members   = ["serviceAccount:${yandex_iam_service_account.resource.id}"]
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = "${yandex_iam_service_account.resource.id}"
  description        = "static access key for object storage"
}
