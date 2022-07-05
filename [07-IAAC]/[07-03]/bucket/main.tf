module "net" {
  source        = "../modules/net"
  description   = "managed by terraform"
  yc_folder_id  = local.folder_id[terraform.workspace]
  name          = terraform.workspace
  subnets       = local.vpc_subnets[terraform.workspace]
}

module "iam" {
  source       = "../modules/iam"
  project_name = terraform.workspace
  folder_id    = local.folder_id[terraform.workspace]
  depends_on = [
    module.net
  ]
}

module "bucket" {
  source     = "../modules/bucket"
  name       = terraform.workspace
  access_key = module.iam.access_key
  secret_key = module.iam.secret_key
  depends_on = [
    module.iam
  ]
}
module "news" {
  source         = "../modules/instance"
  instance_count = local.news_instance_count[terraform.workspace]
  subnet_id      = "module.vpc.subnet_ids[0]"
  zone           = var.yc_region
  folder_id      = local.folder_id[terraform.workspace]
  image          = "centos-7"
  platform_id    = "standard-v2"
  name           = "news"
  description    = "News App Demo"
  instance_role  = "news,balancer"
  users          = "centos"
  cores          = local.news_cores[terraform.workspace]
  boot_disk      = "network-ssd"
  disk_size      = local.news_disk_size[terraform.workspace]
  nat            = "true"
  memory         = "2"
  core_fraction  = "100"
  depends_on = [
    module.bucket
  ]
}
