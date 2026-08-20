module "service" {
  source = "./modules/service"

  app_ami_id    = var.app_ami_id
  instance_type = "t3.small"
  secret_arn    = var.db_secret_arn
  db_endpoint   = var.db_endpoint
  db_port       = var.db_port
}

# module "data" composes in here once Aiven + Secrets Manager (modules/data,
# Phase 2) is ready — its secret_arn / db_endpoint / db_port outputs replace
# the plain variables above, e.g.:
#
# module "data" {
#   source = "./modules/data"
# }
#
# module "service" {
#   ...
#   secret_arn  = module.data.secret_arn
#   db_endpoint = module.data.db_endpoint
#   db_port     = module.data.db_port
# }
