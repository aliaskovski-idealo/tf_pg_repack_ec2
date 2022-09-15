locals {
  name = replace(lower("${var.namespace}-${var.stage}-${var.name}"), "_", "-")
}

resource "aws_sns_topic" "sns_topic" {
  name         = "${local.name}-CloudWatchAlarmsCritical"
  display_name = "CloudWatch Critical Alarms"
  tags         = {}
}

resource "aws_serverlessapplicationrepository_cloudformation_stack" "cloudwatch-alarm-to-ms-teams" {
  name           = "${local.name}-cloudwatch-alarm-to-ms-teams"
  application_id = "arn:aws:serverlessrepo:eu-central-1:482117739457:applications/cloudwatch-alarm-to-ms-teams"
  capabilities = [
    "CAPABILITY_IAM",
  ]
  parameters = {
    AlarmTopicArn     = aws_sns_topic.sns_topic.arn
    MSTeamsWebhookUrl = var.ms_teams_webhook_url
  }
}