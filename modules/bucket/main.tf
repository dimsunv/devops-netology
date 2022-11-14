variable access_key { default =  "" }
variable secret_key { default = ""}


resource "yandex_storage_bucket" "netology" {
  bucket     = "netology-tf-bucket"
  acl        = "private"
  access_key = var.access_key
  secret_key = var.secret_key
}
