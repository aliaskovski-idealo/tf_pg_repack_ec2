locals {
  name = replace(lower("${var.namespace}-${var.stage}-${var.name}"), "_", "-")

  db_engine   = length(regexall("postgres", var.rds_instance_settings.engine)) > 0 ? "postgres" : "mysql"
  db_password = random_password.db_pass.result
  db_endpoint = replace(module.rds_master.db_instance_endpoint, ":${module.rds_master.db_instance_port}", "")

  db_primary_key   = keys(var.db_instances)[0]
  db_secondary_key = keys(var.db_instances)[1]

  default_master_backup_settings = {
    maintenance_window      = "Mon:00:00-Mon:03:00"
    backup_window           = "03:00-06:00"
    backup_retention_period = 1     #Mandatory, (0-35) if there is a replica
    skip_final_snapshot     = true  #Optional
    deletion_protection     = false #Optional
    storage_encrypted       = false #Optional
  }
  default_replica_backup_settings = {
    maintenance_window      = "Tue:00:00-Tue:03:00"
    backup_window           = "03:00-06:00"
    backup_retention_period = 0
    skip_final_snapshot     = true
    deletion_protection     = false
    storage_encrypted       = false
  }

  master_backup_settings  = merge(local.default_master_backup_settings, var.db_instances[local.db_primary_key].backup)
  replica_backup_settings = merge(local.default_replica_backup_settings, var.db_instances[local.db_secondary_key].backup)

  tags = {
    Project = var.namespace
  }
}

resource "random_password" "db_pass" {
  length  = 32
  special = false
}

data "aws_secretsmanager_secret" "rds" {
  depends_on = [module.rds_master]
  arn        = aws_secretsmanager_secret.rds.arn
}

data "aws_secretsmanager_secret_version" "creds" {
  depends_on = [module.rds_master]
  secret_id  = data.aws_secretsmanager_secret.rds.arn
}

resource "aws_secretsmanager_secret" "rds" {
  depends_on              = [module.rds_master]
  name                    = "${local.name}-root_credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id     = aws_secretsmanager_secret.rds.id
  depends_on    = [module.rds_master]
  secret_string = <<EOF
   {
    "username": "${module.rds_master.db_instance_username}",
    "password": "${local.db_password}",
    "engine": "${local.db_engine}",
    "host": "${local.db_endpoint}",
    "port": "${module.rds_master.db_instance_port}",
    "dbInstanceId": "${module.rds_master.db_instance_id}"
   }
EOF
}

resource "aws_security_group" "allow_rds_connect" {
  name        = "${local.name}-allow_rds_inbound"
  description = "Allow RDS inbound traffic"
  vpc_id      = var.vpc

  ingress {
    description = "Allow RDS inbound traffic"
    from_port   = var.rds_instance_settings.db_port
    to_port     = var.rds_instance_settings.db_port
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
    Name = "allow_rds_inbound"
  }

}

resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = var.private_subnet_ids
}

module "rds_master" {
  source               = "terraform-aws-modules/rds/aws"
  identifier           = "${local.name}-${var.db_instances[local.db_primary_key].identifier}"
  engine               = var.rds_instance_settings.engine
  engine_version       = var.rds_instance_settings.engine_version
  family               = var.rds_instance_settings.family
  major_engine_version = var.rds_instance_settings.major_engine_version
  instance_class       = var.db_instances[local.db_primary_key].instance_class

  allocated_storage     = var.rds_instance_settings.allocated_storage     #Mandatory
  max_allocated_storage = var.rds_instance_settings.max_allocated_storage #Mandatory

  db_name                = var.rds_instance_settings.db_name  #"replicaPostgresql"  #Mandatory
  username               = var.rds_instance_settings.username #"replica_postgresql" #Mandatory
  create_random_password = false
  #  TODO: password may show up in logs, and it will be stored in the state file
  password = local.db_password
  port     = var.rds_instance_settings.db_port

  multi_az               = true #Optional
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.allow_rds_connect.id]

  enabled_cloudwatch_logs_exports = var.rds_instance_settings.enabled_cloudwatch_logs_exports

  maintenance_window      = lookup(local.master_backup_settings, "maintenance_window", null)
  backup_window           = lookup(local.master_backup_settings, "backup_window", null)
  backup_retention_period = lookup(local.master_backup_settings, "backup_retention_period", null)
  skip_final_snapshot     = lookup(local.master_backup_settings, "skip_final_snapshot", null)
  deletion_protection     = lookup(local.master_backup_settings, "deletion_protection", null)
  storage_encrypted       = lookup(local.master_backup_settings, "storage_encrypted", null)

  tags = {}
}

module "rds_replica" {
  source     = "terraform-aws-modules/rds/aws"
  identifier = "${local.name}-${var.db_instances[local.db_secondary_key].identifier}"
  # Source database. For cross-region use db_instance_arn
  replicate_source_db    = module.rds_master.db_instance_id
  create_random_password = false

  engine               = var.rds_instance_settings.engine
  engine_version       = var.rds_instance_settings.engine_version
  family               = var.rds_instance_settings.family
  major_engine_version = var.rds_instance_settings.major_engine_version
  instance_class       = var.db_instances[local.db_secondary_key].instance_class

  allocated_storage     = var.rds_instance_settings.allocated_storage
  max_allocated_storage = var.rds_instance_settings.max_allocated_storage

  port = var.rds_instance_settings.db_port

  multi_az               = false
  vpc_security_group_ids = [aws_security_group.allow_rds_connect.id]

  enabled_cloudwatch_logs_exports = var.rds_instance_settings.enabled_cloudwatch_logs_exports

  maintenance_window      = lookup(local.replica_backup_settings, "maintenance_window", null)
  backup_window           = lookup(local.replica_backup_settings, "backup_window", null)
  backup_retention_period = lookup(local.replica_backup_settings, "backup_retention_period", null)
  skip_final_snapshot     = lookup(local.replica_backup_settings, "skip_final_snapshot", null)
  deletion_protection     = lookup(local.replica_backup_settings, "deletion_protection", null)
  storage_encrypted       = lookup(local.replica_backup_settings, "storage_encrypted", null)

  tags = {}
}

module "ec2" {
  count = var.enable_bastion_host ? 1 : 0
  #  enabled           = var.enable_bastion_host
  source            = "../ec2"
  namespace         = var.namespace
  stage             = var.stage
  name              = var.name
  region            = var.aws_region
  vpc               = var.vpc
  public_subnet     = var.public_subnet_ids
  sg_rds_connect_id = length(module.rds_master.db_instance_id) > 0 ? aws_security_group.allow_rds_connect.id : ""
  rds_endpoint      = replace(module.rds_master.db_instance_endpoint, ":${module.rds_master.db_instance_port}", "")
  rds_port          = module.rds_master.db_instance_port
  rds_engine        = var.rds_instance_settings.engine
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
  db_engine          = var.rds_instance_settings.engine
  db_port            = var.rds_instance_settings.db_port
}

module "alerting" {
  count                = var.enable_alerting ? 1 : 0
  source               = "../alerting"
  namespace            = var.namespace
  stage                = var.stage
  name                 = var.name
  instance_alarms      = var.instance_alarms
  db_instances         = var.db_instances
  ms_teams_webhook_url = var.ms_teams_webhook_url
  db_engine            = var.rds_instance_settings.engine
}

#module "rds" {
#  source     = "terraform-aws-modules/rds/aws"
##  source     = ".terraform/modules/rds"
#  identifier = "${local.name}-rds"
#
#  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
#  engine               = "postgres"
#  engine_version       = "14.1"
#  family               = "postgres14" # DB parameter group
#  major_engine_version = "14"         # DB option group
#  instance_class       = "db.t4g.large"
#
#  allocated_storage     = 20
#  max_allocated_storage = 100
#
#  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
#  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
#  # user cannot be used as it is a reserved word used by the engine"
#  db_name  = "completePostgresql"
#  username = "complete_postgresql"
#  password = join("", random_password.db_pass.*.result)
#  port     = 5432
#
#  multi_az               = true
#  db_subnet_group_name   = join("", aws_db_subnet_group.db_subnet_group.*.name)
#  vpc_security_group_ids = [join("", aws_security_group.allow_rds_connect.*.id)]
#
#  maintenance_window              = "Mon:00:00-Mon:03:00"
#  backup_window                   = "03:00-06:00"
#  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
#  create_cloudwatch_log_group     = true
#
#  backup_retention_period = 1
#  skip_final_snapshot     = true
#  deletion_protection     = false
#
#  performance_insights_enabled          = true
#  performance_insights_retention_period = 7
#  create_monitoring_role                = true
#  monitoring_interval                   = 60
#  monitoring_role_name                  = "example-monitoring-role-name"
#  monitoring_role_use_name_prefix       = true
#  monitoring_role_description           = "Description for monitoring role"
#
#  parameters = [
#    {
#      name  = "autovacuum"
#      value = 1
#    },
#    {
#      name  = "client_encoding"
#      value = "utf8"
#    }
#  ]
#
#  tags = local.tags
#  db_option_group_tags = {
#    "Sensitive" = "low"
#  }
#  db_parameter_group_tags = {
#    "Sensitive" = "low"
#  }
#}