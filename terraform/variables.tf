variable "metadata" {
   default = "/home/boliwar/meta.txt"
}
variable "yc_token" {
   default = ""
}

variable "yc_cloud_id" {
  default = ""
}

variable "yc_folder_id" {
  default = "b1g32pblgem5led32rfc"
}

variable "yc_region" {
  default = "ru-central1-a"
}

locals {
# node instance settings
  node_instance_count = {
    vpc = 1
  }
  node_cores = {
    vpc = 2
  }
  node_memory = {
    vpc = 2
  }
  node_disk_size = {
    vpc = 20
  }

#Network settings
  private = {
    vpc = [
    {
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["192.168.20.0/24"]
    }
    ]
  }
}
