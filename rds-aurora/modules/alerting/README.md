<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_serverlessapplicationrepository_cloudformation_stack.cloudwatch-alarm-to-ms-teams](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/serverlessapplicationrepository_cloudformation_stack) | resource |
| [aws_sns_topic.sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_alarms"></a> [cluster\_alarms](#input\_cluster\_alarms) | Define metric based alerts for the cluster instances. | <pre>map(object({<br>    alarm_name          = string<br>    alarm_description   = string<br>    comparison_operator = string<br>    evaluation_periods  = number<br>    threshold           = number<br>    namespace           = string<br>    statistic           = string<br>    period              = number<br>    treat_missing_data  = string<br>  }))</pre> | `{}` | no |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | n/a | `string` | `""` | no |
| <a name="input_db_instances"></a> [db\_instances](#input\_db\_instances) | definition of db instances | <pre>map(object({<br>    identifier          = string<br>    instance_class      = string<br>    publicly_accessible = bool<br>    promotion_tier      = number<br>  }))</pre> | n/a | yes |
| <a name="input_instance_alarms"></a> [instance\_alarms](#input\_instance\_alarms) | Define metric based alerts for the cluster instances. | <pre>map(object({<br>    alarm_name          = string<br>    alarm_description   = string<br>    comparison_operator = string<br>    evaluation_periods  = number<br>    threshold           = number<br>    namespace           = string<br>    statistic           = string<br>    period              = number<br>    treat_missing_data  = string<br>  }))</pre> | `{}` | no |
| <a name="input_ms_teams_webhook_url"></a> [ms\_teams\_webhook\_url](#input\_ms\_teams\_webhook\_url) | URL for MS Teams Webhook. See: https://github.com/idealo/cloudwatch-alarm-to-ms-teams | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the environment. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace or Project name of the environment | `string` | n/a | yes |
| <a name="input_sns_topic_subscriptions"></a> [sns\_topic\_subscriptions](#input\_sns\_topic\_subscriptions) | SNS Subscriptions | <pre>list(object({<br>    name                   = string<br>    protocol               = string<br>    endpoint               = string<br>    endpoint_auto_confirms = bool<br>    raw_message_delivery   = bool<br>    filter_policy          = string<br>  }))</pre> | `[]` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage of the environment. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of SNS topic |
<!-- END_TF_DOCS -->