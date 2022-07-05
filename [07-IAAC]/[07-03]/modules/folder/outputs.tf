output "folder_id" {
  value = var.create_folder ? yandex_resourcemanager_folder.folder[0].id : var.yc_folder_id
}
