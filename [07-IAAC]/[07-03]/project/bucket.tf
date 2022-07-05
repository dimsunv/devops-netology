module "iam" {
  source       = "../modules/iam"
  project_name = terraform.workspace
  folder_id    = module.vpc.folder_id
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
