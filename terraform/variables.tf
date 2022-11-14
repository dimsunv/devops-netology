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
#Base settings
  ansible_inventory = {
    stage = "stage"
    prod = "prod"
  }
  yc_folder_id = {
    stage = "b1gsagv0bv9r7eid3i09"
    prod = "b1ga9abedkhgkfku9fai"
  }
# Clickhouse instance settings
  clickhouse_instance_count = {
    stage = 1
    prod = 1
  }
  clickhouse_cores = {
    stage = 2
    prod = 2
  }
  clickhouse_memory = {
    stage = 4
    prod = 4
  }
  clickhouse_disk_size = {
    stage = 20
    prod = 40
  }
# Lighthouse instance settings
  lihgthouse_instance_count = {
    stage = 1
    prod = 1
  }
  lihgthouse_cores = {
    stage = 2
    prod = 2
  }
  lihgthouse_memory = {
    stage = 4
    prod = 4
  }
  lihgthouse_disk_size = {
    stage = 20
    prod = 20
  }
# Servers instance settings
  server_instance_count = {
    stage = 2
    prod = 1
  }
  server_cores = {
    stage = 2
    prod = 2
  }
  server_memory = {
    stage = 8
    prod = 8
  }
  server_disk_size = {
    stage = 40
    prod = 40
  }
#Network settings
  vpc_subnets = {
    stage = [
      {
        "zone": var.yc_region
        "v4_cidr_blocks": ["172.16.0.0/24"],
      }
    ]
    prod = [
      {
        zone           = "ru-central1-a"
        v4_cidr_blocks = ["172.16.10.0/24"]
      }
    ]
  }
}
