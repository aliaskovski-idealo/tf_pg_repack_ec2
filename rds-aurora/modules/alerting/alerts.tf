locals {

  # transforms map of db_instances into a list.
  instances = [
    for key, value in var.db_instances : {
      key        = key
      identifier = value.identifier
    }
  ]

  # transforms map of instance_alarms into a list.
  alarms = [
    for key, value in var.instance_alarms : {
      key                 = key
      alarm_name          = value.alarm_name
      alarm_description   = value.alarm_description
      comparison_operator = value.comparison_operator
      evaluation_periods  = value.evaluation_periods
      threshold           = value.threshold
      namespace           = value.namespace
      period              = value.period
      statistic           = value.statistic
    }
  ]

  # builds a cross product of alarms and instances.
  instances_with_alarms = [
    for pair in setproduct(local.instances, local.alarms) : merge({
      alarm_name_identifier = "${pair[1].key}-${pair[0].identifier}"
      identifier            = length(regexall("aurora", var.db_engine)) > 0 ? pair[0].identifier : "${local.name}-${pair[0].identifier}"
    }, pair[1])
  ]
}

resource "aws_cloudwatch_metric_alarm" "instance" {
  for_each = { for v in local.instances_with_alarms : v.alarm_name_identifier => v }

  alarm_name        = "${local.name}-${each.value.alarm_name_identifier}"
  alarm_description = each.value.alarm_description

  alarm_actions = aws_sns_topic.sns_topic.*.arn
  ok_actions    = aws_sns_topic.sns_topic.*.arn

  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  threshold           = each.value.threshold

  metric_name = each.value.alarm_name
  namespace   = each.value.namespace
  period      = each.value.period
  statistic   = each.value.statistic

  insufficient_data_actions = []

  tags = {
    Name = each.value.identifier
  }

  dimensions = {
    DBInstanceIdentifier = each.value.identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster" {
  for_each = var.cluster_alarms

  alarm_name        = "${local.name}-${each.value.alarm_name}"
  alarm_description = each.value.alarm_description

  alarm_actions = aws_sns_topic.sns_topic.*.arn
  ok_actions    = aws_sns_topic.sns_topic.*.arn

  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  threshold           = each.value.threshold

  metric_name = each.value.alarm_name
  namespace   = each.value.namespace
  period      = each.value.period
  statistic   = each.value.statistic

  treat_missing_data = each.value.treat_missing_data

  insufficient_data_actions = []
  tags                      = {}

  dimensions = {
    DBClusterIdentifier = local.name
  }
}