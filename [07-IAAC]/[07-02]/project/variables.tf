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
    default = 2
  }
  news_disk_size = {
    default = 20
  }
  news_instance_count = {
    default = 1
  }
  vpc_subnets = {
    default = [
      {
        "v4_cidr_blocks": [
          "172.16.10.0/24"
        ],
        "zone": var.yc_region
      }
    ]
  }
}
