terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.61.0"
    }
  }
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "netology-tf-prod-bucket"
    region     = "ru-central1-a"
    key        = "netology/terraform.tfstate"
    access_key = "YCAJE23aCUBEMS-e_m80yJse-"
    secret_key = "YCPFnarcok4s0_VHn4XRi1KeoUS4HSemMAVpDki1"

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
