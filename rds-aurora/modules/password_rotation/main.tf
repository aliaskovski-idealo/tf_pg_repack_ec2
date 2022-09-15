
locals {
  name = replace(lower("${var.namespace}-${var.stage}-${var.name}"), "_", "-")

  db_engine = length(regexall("postgres", var.db_engine)) > 0 ? "postgres" : "mysql"

  mysql_application_id    = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSMySQLRotationSingleUser"
  postgres_application_id = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSPostgreSQLRotationSingleUser"

  tags = {
    Project = var.namespace
  }
}

data "aws_serverlessapplicationrepository_application" "secrets_rotator_application" {
  application_id = length(regexall("postgres", local.db_engine)) > 0 ? local.postgres_application_id : local.mysql_application_id
}

data "aws_partition" "current" {}
data "aws_region" "current" {}


resource "aws_serverlessapplicationrepository_cloudformation_stack" "secrets_rotator_stack" {
  name             = "Rotate-${local.name}-1"
  application_id   = data.aws_serverlessapplicationrepository_application.secrets_rotator_application.application_id
  semantic_version = data.aws_serverlessapplicationrepository_application.secrets_rotator_application.semantic_version
  capabilities     = data.aws_serverlessapplicationrepository_application.secrets_rotator_application.required_capabilities

  parameters = {
    endpoint            = "https://secretsmanager.${data.aws_region.current.name}.${data.aws_partition.current.dns_suffix}"
    functionName        = "Rotate-${local.name}"
    vpcSubnetIds        = var.private_subnet_ids[0] #TODO: why does vpcSubnetIds from aws_serverlessapplicationrepository_cloudformation_stack is not a list?
    vpcSecurityGroupIds = aws_security_group.allow_access_secrets_manager.id
  }
}

# secrets_manager_elastic_ip, nat-routing, route_table_association only needed in case of basic vpc version < v6

#resource "aws_eip" "secrets_manager_elastic_ip" {
#  vpc = true
#}
#
#resource "aws_nat_gateway" "secrets_manager_nat_gw" {
#  allocation_id = aws_eip.secrets_manager_elastic_ip.allocation_id
#  subnet_id     = var.public_subnet_ids[0]
#  tags          = {}
#}
#
#resource "aws_route_table" "nat-routing" {
#  vpc_id = var.vpc
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_nat_gateway.secrets_manager_nat_gw.id
#  }
#  lifecycle {
#    ignore_changes = [
#      route
#    ]
#  }
#  tags = {}
#}
#
#resource "aws_route_table_association" "route_table_association" {
#  count          = length(var.private_subnet_ids)
#  subnet_id      = var.private_subnet_ids[count.index]
#  route_table_id = aws_route_table.nat-routing.id
#}

resource "aws_security_group" "allow_access_secrets_manager" {
  name        = "${local.name}-allow_outbound_access_to_services"
  description = "Allow outbound traffic necessary services"
  vpc_id      = var.vpc

  egress {
    description = "TLS to database from secret-manager"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Database connection from secrets-manager"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-allow_outbound_access"
  }
}


resource "aws_secretsmanager_secret_rotation" "secretsmanager_secret_rotation" {
  secret_id           = var.secret_id
  rotation_lambda_arn = aws_serverlessapplicationrepository_cloudformation_stack.secrets_rotator_stack.outputs.RotationLambdaARN
  rotation_rules {
    automatically_after_days = 30
  }
}