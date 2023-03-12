module "vpc" {
  source = "../modules/vpc"
  description   = "managed by terraform"
  create_folder = length(var.yc_folder_id) > 0 ? false : true
  yc_folder_id  = var.yc_folder_id
  name          = terraform.workspace
  subnets       = local.vpc_subnets[terraform.workspace]
}

#yc images: ubuntu-2204-lts debian-11 centos-stream-8
module "node" {
  source         = "../modules/instance"
  instance_count = local.node_instance_count[terraform.workspace]
  subnet_id      = module.vpc.subnet_ids[0]
  zone           = var.yc_region
  folder_id      = module.vpc.folder_id
  image          = "centos-stream-8"
  platform_id    = "standard-v2"
  name           = "node"
  description    = "Prod"
  instance_role  = "netology_k8s_cluster"
  cores          = local.node_cores[terraform.workspace]
  boot_disk      = "network-hdd"
  disk_size      = local.node_disk_size[terraform.workspace]
  nat            = "true"
  memory         = local.node_memory[terraform.workspace]
  core_fraction  = "100"
  
  depends_on = [
    module.vpc
  ]
}

