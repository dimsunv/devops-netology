variable access_key { default =  "" }
variable secret_key { default = ""}
variable name { default =  "" }


resource "yandex_storage_bucket" "netology" {
  bucket     = "${var.name}-tf-bucket"
  acl        = "private"
  access_key = var.access_key
  secret_key = var.secret_key
}
