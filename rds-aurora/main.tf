locals {
  is_aurora = var.is_aurora
  is_rds    = !local.is_aurora
}

module "aurora" {
  source                   = "./modules/aurora"
  count                    = local.is_aurora ? 1 : 0
  enable_alerting          = var.enable_alerting
  enable_password_rotation = var.enable_password_rotation
  enable_bastion_host      = var.enable_bastion_host
  aws_region               = var.region
  namespace                = var.namespace
  stage                    = var.stage
  name                     = var.name
  cluster_alarms           = var.cluster_alarms
  db_instances             = var.db_instances
  instance_alarms          = var.instance_alarms
  ms_teams_webhook_url     = var.ms_teams_webhook_url
  private_subnet_ids       = var.private_subnet_ids
  public_subnet_ids        = var.public_subnet_ids
  rds_cluster_settings     = var.rds_cluster_settings
  vpc                      = var.vpc_id
}

module "rds" {
  source                   = "./modules/rds"
  count                    = local.is_rds ? 1 : 0
  enable_password_rotation = var.enable_password_rotation
  enable_alerting          = var.enable_alerting
  enable_bastion_host      = var.enable_bastion_host
  aws_region               = var.region
  namespace                = var.namespace
  stage                    = var.stage
  name                     = var.name
  db_instances             = var.db_instances
  instance_alarms          = var.instance_alarms
  ms_teams_webhook_url     = var.ms_teams_webhook_url
  private_subnet_ids       = var.private_subnet_ids
  public_subnet_ids        = var.public_subnet_ids
  rds_instance_settings    = var.rds_instance_settings
  vpc                      = var.vpc_id
}