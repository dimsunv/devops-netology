module "folder" {
  source        = "../modules/folder"
  name          = "storage"
  description   = "managed by terraform"
  create_folder = length(var.yc_folder_id) > 0 ? false : true
  yc_folder_id  = var.yc_folder_id
}

module "iam" {
  source       = "../modules/iam"
  project_name = terraform.workspace
  folder_id    = module.folder.folder_id
  depends_on = [
    module.folder
  ]
}

module "bucket" {
  source     = "../modules/bucket"
  access_key = module.iam.access_key
  secret_key = module.iam.secret_key
  depends_on = [
    module.iam
  ]
}
