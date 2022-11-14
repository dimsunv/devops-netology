variable "yc_token" {
   default = ""
}

variable "yc_cloud_id" {
  default = ""
}

variable "yc_folder_id" {
  default = ""
}

variable "yc_region" {
  default = "ru-central1-a"
}

locals {
  news_cores = {
    stage = 2
    prod = 2
  }
  news_disk_size = {
    stage = 20
    prod = 40
  }
  news_instance_count = {
    stage = 1
    prod = 2
  }

  vpc_subnets = {
    stage = [
      {
        "v4_cidr_blocks": ["172.16.0.0/24"],
        "zone": var.yc_region
      }
    ]
    prod = [
      {
        zone           = "ru-central1-a"
        v4_cidr_blocks = ["172.16.0.0/24"]
      },
      {
        zone           = "ru-central1-b"
        v4_cidr_blocks = ["172.17.0.0/24"]
      },
      {
        zone           = "ru-central1-c"
        v4_cidr_blocks = ["172.18.0.0/24"]
      }
    ]
  }
}
