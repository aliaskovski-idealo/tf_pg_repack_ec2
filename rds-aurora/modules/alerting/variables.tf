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

variable "db_instances" {
  type = map(object({
    identifier          = string
    instance_class      = string
    publicly_accessible = bool
    promotion_tier      = number
  }))
  description = "definition of db instances"
}

#-----------------------------------------------------------
# SNS topic subscription
#-----------------------------------------------------------
variable "sns_topic_subscriptions" {
  type = list(object({
    name                   = string
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = bool
    raw_message_delivery   = bool
    filter_policy          = string
  }))
  default     = []
  description = "SNS Subscriptions"
}

# Alerting

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

variable "ms_teams_webhook_url" {
  type        = string
  description = "URL for MS Teams Webhook. See: https://github.com/idealo/cloudwatch-alarm-to-ms-teams"
  default     = ""
}

variable "db_engine" {
  type    = string
  default = ""
}