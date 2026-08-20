module "data" {
  source = "./modules/data"

  aiven_project = var.aiven_project
  aiven_plan    = var.aiven_plan
}

module "service" {
  source = "./modules/service"

  app_ami_id    = var.app_ami_id
  instance_type = "t3.small"
  secret_arn    = module.data.secret_arn
  db_endpoint   = module.data.db_endpoint
  db_port       = module.data.db_port
}
