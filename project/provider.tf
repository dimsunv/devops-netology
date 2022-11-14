terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "netology-tf-bucket"
    region     = "ru-central1-a"
    key        = "netology/terraform.tfstate"
    access_key = "YХХХХХХХХХХХХХХ3"
    secret_key = "YХХХХХХХХХХХХХХХХХХХХХХХХu"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  zone      = var.yc_region
}
