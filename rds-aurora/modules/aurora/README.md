<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alerting"></a> [alerting](#module\_alerting) | ../alerting | n/a |
| <a name="module_ec2"></a> [ec2](#module\_ec2) | ../ec2 | n/a |
| <a name="module_password_rotation"></a> [password\_rotation](#module\_password\_rotation) | ../password_rotation | n/a |
| <a name="module_rds_aurora"></a> [rds\_aurora](#module\_rds\_aurora) | terraform-aws-modules/rds-aurora/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_subnet_group.db_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_rds_cluster_parameter_group.aws_rds_cluster_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |
| [aws_secretsmanager_secret.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.sversion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.allow_rds_connect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.db_pass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_secretsmanager_secret.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.creds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_cluster_alarms"></a> [cluster\_alarms](#input\_cluster\_alarms) | Define metric based alerts for the cluster instances. | <pre>map(object({<br>    alarm_name          = string<br>    alarm_description   = string<br>    comparison_operator = string<br>    evaluation_periods  = number<br>    threshold           = number<br>    namespace           = string<br>    statistic           = string<br>    period              = number<br>    treat_missing_data  = string<br>  }))</pre> | n/a | yes |
| <a name="input_cluster_parameters"></a> [cluster\_parameters](#input\_cluster\_parameters) | n/a | `list(map(string))` | `[]` | no |
| <a name="input_db_instances"></a> [db\_instances](#input\_db\_instances) | definition of db instances | <pre>map(object({<br>    identifier          = string<br>    instance_class      = string<br>    publicly_accessible = bool<br>    promotion_tier      = number<br>  }))</pre> | n/a | yes |
| <a name="input_enable_alerting"></a> [enable\_alerting](#input\_enable\_alerting) | Alerting | `bool` | `true` | no |
| <a name="input_enable_bastion_host"></a> [enable\_bastion\_host](#input\_enable\_bastion\_host) | Set to `true` to allow the module to create any resources for the ec2 bastion host. | `bool` | `false` | no |
| <a name="input_enable_password_rotation"></a> [enable\_password\_rotation](#input\_enable\_password\_rotation) | n/a | `bool` | n/a | yes |
| <a name="input_instance_alarms"></a> [instance\_alarms](#input\_instance\_alarms) | Define metric based alerts for the cluster instances. | <pre>map(object({<br>    alarm_name          = string<br>    alarm_description   = string<br>    comparison_operator = string<br>    evaluation_periods  = number<br>    threshold           = number<br>    namespace           = string<br>    statistic           = string<br>    period              = number<br>    treat_missing_data  = string<br>  }))</pre> | n/a | yes |
| <a name="input_ms_teams_webhook_url"></a> [ms\_teams\_webhook\_url](#input\_ms\_teams\_webhook\_url) | URL for MS Teams Webhook. See: https://github.com/idealo/cloudwatch-alarm-to-ms-teams | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the environment. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace or Project name of the environment | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of already existing private subnets. | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of already existing public subnets. | `list(string)` | n/a | yes |
| <a name="input_rds_cluster_settings"></a> [rds\_cluster\_settings](#input\_rds\_cluster\_settings) | engine:             The database engine to use: postgres\|mysql<br>    engine\_version:     (Optional) The engine version to use. If auto\_minor\_version\_upgrade is enabled, you can provide a<br>                        prefix of the version such as 5.7 (for 5.7.10). The actual engine version used is returned in the<br>                        attribute engine\_version\_actual, see Attributes Reference below. For supported values, see the<br>                        EngineVersion parameter in API action CreateDBInstance. Note that for Amazon Aurora instances the<br>                        engine version must match the DB cluster's engine version'. Cannot be specified for a replica.<br>    cluster\_family:     The family of the DB parameter group<br>    enabled\_cloudwatch\_logs\_exports:<br>                        https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#enabled_cloudwatch_logs_exports<br>    db\_port:            The port to use for the db system<br>    cluster\_parameters: Additional cluster parameters.<br>    backup:             Backup configuration for aurora cluster. | <pre>object({<br>    engine                          = string<br>    engine_version                  = string<br>    cluster_family                  = string<br>    enabled_cloudwatch_logs_exports = list(string)<br>    db_port                         = number<br>    cluster_parameters = list(object({<br>      name         = string<br>      value        = string<br>      apply_method = string<br>    }))<br>    backup = any<br>  })</pre> | <pre>{<br>  "backup": null,<br>  "cluster_family": "aurora-postgresql14",<br>  "cluster_parameters": [<br>    {<br>      "apply_method": "immediate",<br>      "name": "timezone",<br>      "value": "Europe/Prague"<br>    }<br>  ],<br>  "db_port": 5432,<br>  "enabled_cloudwatch_logs_exports": [<br>    "postgresql"<br>  ],<br>  "engine": "aurora-postgresql",<br>  "engine_version": "14.3"<br>}</pre> | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage of the environment. | `string` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_members"></a> [cluster\_members](#output\_cluster\_members) | List of RDS Instances that are a part of this cluster |
| <a name="output_rds_cluster_database_name"></a> [rds\_cluster\_database\_name](#output\_rds\_cluster\_database\_name) | Name for an automatically created database on cluster creation |
| <a name="output_rds_cluster_endpoint"></a> [rds\_cluster\_endpoint](#output\_rds\_cluster\_endpoint) | The cluster endpoint |
| <a name="output_rds_cluster_id"></a> [rds\_cluster\_id](#output\_rds\_cluster\_id) | The ID of the cluster |
| <a name="output_rds_cluster_master_username"></a> [rds\_cluster\_master\_username](#output\_rds\_cluster\_master\_username) | The master username |
| <a name="output_rds_cluster_port"></a> [rds\_cluster\_port](#output\_rds\_cluster\_port) | The port |
| <a name="output_rds_cluster_reader_endpoint"></a> [rds\_cluster\_reader\_endpoint](#output\_rds\_cluster\_reader\_endpoint) | The cluster reader endpoint |
| <a name="output_rds_cluster_resource_id"></a> [rds\_cluster\_resource\_id](#output\_rds\_cluster\_resource\_id) | The Resource ID of the cluster |
| <a name="output_rds_password"></a> [rds\_password](#output\_rds\_password) | n/a |
| <a name="output_rds_secret_id"></a> [rds\_secret\_id](#output\_rds\_secret\_id) | n/a |
| <a name="output_rds_secret_name"></a> [rds\_secret\_name](#output\_rds\_secret\_name) | n/a |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The security group ID of the cluster |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of SNS topic |
<!-- END_TF_DOCS -->