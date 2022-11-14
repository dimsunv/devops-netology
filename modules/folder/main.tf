resource "yandex_resourcemanager_folder" "folder" {
  count = var.create_folder ? 1 : 0
  cloud_id = var.yc_cloud_id
  name = var.name
  description = "terraform managed"
}
