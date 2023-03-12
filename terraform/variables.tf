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

variable "kubespray_cluster_path" {
  default = "/home/boliwar/kubespray/inventory/mycluster"
}

variable "kubespray_config_path" {
  default = "/home/boliwar/kubespray/inventory/mycluster/group_vars/k8s_cluster"
}

locals {
# node instance settings
  node_instance_count = {
    kube = 3
  }
  node_cores = {
    kube = 2
  }
  node_memory = {
    kube = 4
  }
  node_disk_size = {
    kube = 50
  }

#Network settings
  vpc_subnets = {
    kube = [
    {
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["10.130.0.0/24"]
    },
    {
      zone           = "ru-central1-b"
      v4_cidr_blocks = ["10.129.0.0/24"]
    },
    {
      zone           = "ru-central1-c"
      v4_cidr_blocks = ["10.128.0.0/24"]
    }
    ]
  }
}
