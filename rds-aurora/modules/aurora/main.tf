locals {
  name = replace(lower("${var.namespace}-${var.stage}-${var.name}"), "_", "-")

  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )

  db_engine   = length(regexall("postgres", var.rds_cluster_settings.engine)) > 0 ? "postgres" : "mysql"
  db_password = random_password.db_pass.result

  mysql_application_id    = "arn:aws:serverlessrepo:eu-central-1:482117739457::applications/SecretsManagerRDSMySQLRotationSingleUser"
  postgres_application_id = "arn:aws:serverlessrepo:eu-central-1:482117739457::applications/SecretsManagerRDSPostgreSQLRotationSingleUser"

  default_backup_settings = {
    preferred_maintenance_window = "Mon:00:00-Mon:03:00"
    preferred_backup_window      = "03:00-06:00"
    backup_retention_period      = 7
    skip_final_snapshot          = true
    deletion_protection          = false
    storage_encrypted            = true
  }

  backup_settings = merge(local.default_backup_settings, var.rds_cluster_settings.backup)

  tags = {
    Project = var.namespace
  }
}

data "aws_secretsmanager_secret" "rds" {
  depends_on = [module.rds_aurora]
  arn        = aws_secretsmanager_secret.rds.arn
}

data "aws_secretsmanager_secret_version" "creds" {
  depends_on = [module.rds_aurora]
  secret_id  = data.aws_secretsmanager_secret.rds.arn
}

resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = var.private_subnet_ids
}

resource "aws_rds_cluster_parameter_group" "aws_rds_cluster_parameter_group" {
  name   = "${local.name}-rds-cluster-pg"
  family = var.rds_cluster_settings.cluster_family

  dynamic "parameter" {
    for_each = var.rds_cluster_settings.cluster_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "immediate")
    }
  }
}

resource "aws_security_group" "allow_rds_connect" {
  name        = "${local.name}-allow_aurora_inbound"
  description = "Allow Aurora inbound traffic"
  vpc_id      = var.vpc

  ingress {
    description = "Allow Aurora inbound traffic"
    from_port   = var.rds_cluster_settings.db_port
    to_port     = var.rds_cluster_settings.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_aurora_inbound"
  }

}

module "rds_aurora" {
  create_cluster         = true
  source                 = "terraform-aws-modules/rds-aurora/aws"
  name                   = local.name
  engine                 = var.rds_cluster_settings.engine
  engine_version         = var.rds_cluster_settings.engine_version
  instances              = var.db_instances
  vpc_id                 = var.vpc
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  create_db_subnet_group = false
  create_security_group  = true
  #  allowed_cidr_blocks    = [var.vpc_cidr_block]
  vpc_security_group_ids = aws_security_group.allow_rds_connect[*].id

  iam_database_authentication_enabled = false
  master_password                     = local.db_password
  create_random_password              = false

  apply_immediately = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aws_rds_cluster_parameter_group.id
  enabled_cloudwatch_logs_exports = var.rds_cluster_settings.enabled_cloudwatch_logs_exports

  backup_retention_period      = lookup(local.backup_settings, "backup_retention_period", null)
  preferred_maintenance_window = lookup(local.backup_settings, "preferred_maintenance_window", null)
  preferred_backup_window      = lookup(local.backup_settings, "preferred_backup_window", null)
  skip_final_snapshot          = lookup(local.backup_settings, "skip_final_snapshot", true)
  deletion_protection          = lookup(local.backup_settings, "deletion_protection", false)
  storage_encrypted            = lookup(local.backup_settings, "storage_encrypted", true)

  tags = local.tags
}

module "ec2" {
  count             = var.enable_bastion_host ? 1 : 0
  source            = "../ec2"
  namespace         = var.namespace
  stage             = var.stage
  name              = var.name
  region            = var.aws_region
  vpc               = var.vpc
  public_subnet     = var.public_subnet_ids
  sg_rds_connect_id = module.rds_aurora.security_group_id
  rds_endpoint      = module.rds_aurora.cluster_endpoint
  rds_port          = module.rds_aurora.cluster_port
  rds_engine        = var.rds_cluster_settings.engine
}

module "password_rotation" {
  count              = var.enable_password_rotation ? 1 : 0
  source             = "../password_rotation"
  aws_region         = var.aws_region
  namespace          = var.namespace
  stage              = var.stage
  name               = var.name
  vpc                = var.vpc
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids
  secret_id          = aws_secretsmanager_secret_version.sversion.secret_id
  db_engine          = var.rds_cluster_settings.engine
  db_port            = var.rds_cluster_settings.db_port
}

module "alerting" {
  count                = var.enable_alerting ? 1 : 0
  source               = "../alerting"
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  cluster_alarms       = var.cluster_alarms
  instance_alarms      = var.instance_alarms
  db_instances         = var.db_instances
  ms_teams_webhook_url = var.ms_teams_webhook_url
  db_engine            = var.rds_cluster_settings.engine
}

# generate random password
resource "random_password" "db_pass" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "rds" {
  depends_on              = [module.rds_aurora]
  name                    = "${local.name}-aurora-root_credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id  = aws_secretsmanager_secret.rds.id
  depends_on = [module.rds_aurora]
  # We cannot use "${var.rds_engine}". The value needs to be "mysql" instead of mysql-aurora!
  secret_string = <<EOF
   {
    "username": "${module.rds_aurora.cluster_master_username}",
    "password": "${local.db_password}",
    "engine": "${local.db_engine}",
    "host": "${module.rds_aurora.cluster_endpoint}",
    "port": "${module.rds_aurora.cluster_port}",
    "dbClusterIdentifier": "${module.rds_aurora.cluster_id}"
   }
EOF
}
