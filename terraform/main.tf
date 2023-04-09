module "vpc" {
  source = "../modules/vpc"
  description   = "managed by terraform"
  create_folder = length(var.yc_folder_id) > 0 ? false : true
  yc_folder_id  = var.yc_folder_id
  name          = terraform.workspace
  subnets       = local.private[terraform.workspace]
  nat_instance  = true
  metadata_file = var.metadata
}
module "node" {
  source         = "../modules/instance"
  instance_count = local.node_instance_count[terraform.workspace]
  subnet_id      = module.vpc.subnet_ids[0]
  zone           = var.yc_region
  folder_id      = module.vpc.folder_id
  image          = "ubuntu-2204-lts"
  platform_id    = "standard-v2"
  name           = "private-node"
  description    = "private"
  instance_role  = "private"
  cores          = local.node_cores[terraform.workspace]
  boot_disk      = "network-hdd"
  disk_size      = local.node_disk_size[terraform.workspace]
  nat            = "false"
  memory         = local.node_memory[terraform.workspace]
  core_fraction  = "100"
  metadata_file  = var.metadata
  
  depends_on = [
    module.vpc
  ]
}

resource "local_file" "ssh_config" {
  content = templatefile("template/ssh_config.tmpl",
    {
      
      bastion_ip = module.vpc.bastion_public_ip[0]
    
    }
  )
  filename = "/home/boliwar/.ssh/config"

  depends_on = [
    module.node
  ]
}

