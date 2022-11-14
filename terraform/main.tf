module "vpc" {
  source        = "../modules/vpc"
  description   = "managed by terraform"
  # create_folder = length(var.yc_folder_id) > 0 ? false : true
  yc_folder_id  = local.yc_folder_id[terraform.workspace]
  name          = terraform.workspace
  subnets       = local.vpc_subnets[terraform.workspace]
}
#yc images: ubuntu-2204-lts debian-11 centos-stream-8
module "clickhouse" {
  source         = "../modules/instance"
  instance_count = local.clickhouse_instance_count[terraform.workspace]
  subnet_id      = module.vpc.subnet_ids[0]
  zone           = var.yc_region
  folder_id      = local.yc_folder_id[terraform.workspace]
  image          = "ubuntu-2204-lts"
  platform_id    = "standard-v2"
  users          = "boliwar"
  name           = "clickhouse"
  description    = "Prod"
  instance_role  = "clickhouse"
  cores          = local.clickhouse_cores[terraform.workspace]
  boot_disk      = "network-ssd"
  disk_size      = local.clickhouse_disk_size[terraform.workspace]
  nat            = "true"
  memory         = local.clickhouse_memory[terraform.workspace]
  core_fraction  = "100"

  depends_on = [
    module.vpc
  ]
}

module "lighthouse" {
  source         = "../modules/instance"
  instance_count = local.lihgthouse_instance_count[terraform.workspace]
  subnet_id      = module.vpc.subnet_ids[0]
  zone           = var.yc_region
  folder_id      = local.yc_folder_id[terraform.workspace]
  image          = "ubuntu-2204-lts"
  platform_id    = "standard-v2"
  users          = "boliwar"
  name           = "lighthouse"
  description    = "Prod"
  instance_role  = "lighthouse + nginx"
  cores          = local.lihgthouse_cores[terraform.workspace]
  boot_disk      = "network-ssd"
  disk_size      = local.lihgthouse_disk_size[terraform.workspace]
  nat            = "true"
  memory         = local.lihgthouse_memory[terraform.workspace]
  core_fraction  = "100"

  depends_on = [
    module.clickhouse
  ]
}

module "server" {
  source = "../modules/instance"
  instance_count = local.server_instance_count[terraform.workspace]
  subnet_id     = module.vpc.subnet_ids[0]
  zone          = var.yc_region
  folder_id     = local.yc_folder_id[terraform.workspace]
  image         = "ubuntu-2204-lts"
  platform_id   = "standard-v2"
  users         = "boliwar"
  name          = "server"
  description   = "Prod"
  instance_role = "App_server"
  cores         = local.server_cores[terraform.workspace]
  boot_disk     = "network-ssd"
  disk_size     = local.server_disk_size[terraform.workspace]
  nat           = "true"
  memory        = local.server_memory[terraform.workspace]
  core_fraction = "100"

  depends_on = [
    module.lighthouse
  ]
}
