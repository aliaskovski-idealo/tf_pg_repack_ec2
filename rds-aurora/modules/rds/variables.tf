variable "aws_region" {
  type = string
}

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

variable "vpc" {
  type = any
}

variable "private_subnet_ids" {
  description = "List of already existing private subnets."
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
}

variable "db_instances" {
  type = map(object({
    identifier          = string
    instance_class      = string
    publicly_accessible = bool
    promotion_tier      = number
    backup              = any
  }))
  description = "definition of db instances"
  validation {
    condition     = length(var.db_instances) == 2
    error_message = "You need to configure two instances."
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
  validation {
    condition     = length(regexall("aurora", var.rds_instance_settings.engine)) == 0
    error_message = "The engine needs to be postgres or mysql!"
  }
}

variable "enable_password_rotation" {
  type = bool
}

variable "enable_alerting" {
  type    = bool
  default = true
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
}

variable "ms_teams_webhook_url" {
  type        = string
  description = "URL for MS Teams Webhook. See: https://github.com/idealo/cloudwatch-alarm-to-ms-teams"
  default     = ""
}

variable "public_subnet_ids" {
  description = "List of already existing public subnets."
  type        = list(string)
}

variable "enable_bastion_host" {
  description = "Set to `true` to allow the module to create any resources for the ec2 bastion host."
  type        = bool
  default     = false
}
