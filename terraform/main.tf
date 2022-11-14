module "vpc" {
  source        = "../modules/vpc"
  description   = "managed by terraform"
  create_folder = length(var.yc_folder_id) > 0 ? false : true
  yc_folder_id  = var.yc_folder_id
  name          = terraform.workspace
  subnets       = local.vpc_subnets[terraform.workspace]
}

module "clickhouse" {
  source = "../modules/instance"
  instance_count = local.news_instance_count[terraform.workspace]

  subnet_id     = module.vpc.subnet_ids[0]
  zone          = var.yc_region
  folder_id     = module.vpc.folder_id
  image         = "centos-7"
  platform_id   = "standard-v2"
  name          = "clickhouse"
  description   = "Clickhouse Demo"
  instance_role = "clickhouse"
  users         = "centos"
  cores         = local.news_cores[terraform.workspace]
  boot_disk     = "network-ssd"
  disk_size     = local.news_disk_size[terraform.workspace]
  nat           = "true"
  memory        = "2"
  core_fraction = "100"

  depends_on = [
    module.vpc
  ]
}

module "vector" {
  source = "../modules/instance"
  instance_count = local.news_instance_count[terraform.workspace]

  subnet_id     = module.vpc.subnet_ids[0]
  zone          = var.yc_region
  folder_id     = module.vpc.folder_id
  image         = "centos-7"
  platform_id   = "standard-v2"
  name          = "vector"
  description   = "Vector Demo"
  instance_role = "vector"
  users         = "centos"
  cores         = local.news_cores[terraform.workspace]
  boot_disk     = "network-ssd"
  disk_size     = local.news_disk_size[terraform.workspace]
  nat           = "true"
  memory        = "2"
  core_fraction = "100"

  depends_on = [
    module.clickhouse
  ]
}
