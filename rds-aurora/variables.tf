variable "namespace" {
  description = "Namespace or Project name of the environment"
  type        = string
}

variable "stage" {
  description = "Stage of the environment."
  type        = string
}

variable "name" {
  description = "Name of the environment."
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

################################################################################
# Bastion Host
################################################################################

variable "enable_bastion_host" {
  description = "Set to `true` to allow the module to create any resources for the ec2 bastion host."
  type        = bool
  default     = false
}

################################################################################
# Database
################################################################################

variable "is_aurora" {
  description = "Activates aurora module."
  type        = bool
  default     = true
}


variable "rds_cluster_settings" {
  description = <<EOH
    engine:             The database engine to use: postgres|mysql
    engine_version:     (Optional) The engine version to use. If auto_minor_version_upgrade is enabled, you can provide a
                        prefix of the version such as 5.7 (for 5.7.10). The actual engine version used is returned in the
                        attribute engine_version_actual, see Attributes Reference below. For supported values, see the
                        EngineVersion parameter in API action CreateDBInstance. Note that for Amazon Aurora instances the
                        engine version must match the DB cluster's engine version'. Cannot be specified for a replica.
    cluster_family:     The family of the DB parameter group
    enabled_cloudwatch_logs_exports:
                        https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#enabled_cloudwatch_logs_exports
    db_port:            The port to use for the db system
    cluster_parameters: Additional cluster parameters.
    backup:             Backup configuration for aurora cluster.
EOH
  type = object({
    engine                          = string
    engine_version                  = string
    cluster_family                  = string
    enabled_cloudwatch_logs_exports = list(string)
    db_port                         = number
    cluster_parameters = list(object({
      name         = string
      value        = string
      apply_method = string
    }))
    backup = any
  })
  default = {
    engine                          = "aurora-postgresql"
    engine_version                  = "14.3"
    cluster_family                  = "aurora-postgresql14"
    enabled_cloudwatch_logs_exports = ["postgresql"]
    db_port                         = 5432
    cluster_parameters = [
      {
        name         = "timezone"
        value        = "Europe/Prague"
        apply_method = "immediate"
      }
    ]
    backup = null
  }
  validation {
    condition     = length(regexall("aurora-postgresql|aurora-mysql", var.rds_cluster_settings.engine)) > 0
    error_message = "The engine needs to be aurora-postgresql or aurora-mysql!"
  }
}

variable "rds_instance_settings" {
  description = <<EOH
    engine:           The database engine to use: postgres|mysql
    engine_version:   (Optional) The engine version to use. If auto_minor_version_upgrade is enabled, you can provide a
                      prefix of the version such as 5.7 (for 5.7.10). The actual engine version used is returned in the
                      attribute engine_version_actual, see Attributes Reference below. For supported values, see the
                      EngineVersion parameter in API action CreateDBInstance. Note that for Amazon Aurora instances the
                      engine version must match the DB cluster's engine version'. Cannot be specified for a replica.
    family:           The family of the DB parameter group
    enabled_cloudwatch_logs_exports:
                      https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#enabled_cloudwatch_logs_exports
    db_port:          The port to use for the db system
    allocated_storage:
                      The allocated storage in gigabytes
    max_allocated_storage:
                      Specifies the value for Storage Autoscaling
    db_name:          The DB name to create. If omitted, no database is created initially
    username:         Username for the master DB user
EOH
  type = object({
    engine                          = string
    engine_version                  = string
    major_engine_version            = string
    family                          = string
    enabled_cloudwatch_logs_exports = list(string)
    db_port                         = number
    allocated_storage               = number
    max_allocated_storage           = number
    db_name                         = string
    username                        = string
  })
  default = {
    engine                          = "postgres"
    engine_version                  = "14.1"
    major_engine_version            = "14"
    family                          = "postgres14"
    enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
    db_port                         = 5432
    allocated_storage               = 20
    max_allocated_storage           = 100
    db_name                         = "replicaPostgresql"
    username                        = "replica_postgresql"
  }
  validation {
    condition     = length(regexall("aurora", var.rds_instance_settings.engine)) == 0
    error_message = "The engine needs to be postgres or mysql!"
  }
}


variable "ms_teams_webhook_url" {
  type        = string
  description = "URL for MS Teams Webhook. See: https://github.com/idealo/cloudwatch-alarm-to-ms-teams"
  default     = null
}

variable "db_instances" {
  type = map(object({
    identifier          = string
    instance_class      = string
    publicly_accessible = bool
    promotion_tier      = number
    backup              = any #TODO: change it in the future to optional(any). At the moment it is an opt-in experiment!
  }))
  description = "definition of db instances"
}

variable "enable_password_rotation" {
  type    = bool
  default = false
}

################################################################################
# Networking
################################################################################

variable "vpc_id" {
  description = "VPC id of an already existing vpc."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of already existing private subnets."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of already existing public subnets."
  type        = list(string)
}

variable "enable_alerting" {
  type    = bool
  default = false
}

# Alerts

variable "cluster_alarms" {
  description = "Define metric based alerts for the cluster instances."
  type = map(object({
    alarm_name          = string
    alarm_description   = string
    comparison_operator = string
    evaluation_periods  = number
    threshold           = number
    namespace           = string
    statistic           = string
    period              = number
    treat_missing_data  = string
  }))
  default = {}
}

variable "instance_alarms" {
  description = "Define metric based alerts for the cluster instances."
  type = map(object({
    alarm_name          = string
    alarm_description   = string
    comparison_operator = string
    evaluation_periods  = number
    threshold           = number
    namespace           = string
    statistic           = string
    period              = number
    treat_missing_data  = string
  }))
  default = {}
}
