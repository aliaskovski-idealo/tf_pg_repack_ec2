module "cluster" {
  source                   = "../../"
  is_aurora                = var.is_aurora
  enable_alerting          = var.enable_alerting
  enable_password_rotation = var.enable_password_rotation
  enable_bastion_host      = var.enable_bastion_host
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
  vpc_id                   = var.vpc_id
}