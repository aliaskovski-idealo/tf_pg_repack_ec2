<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret_rotation.secretsmanager_secret_rotation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | resource |
| [aws_security_group.allow_access_secrets_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_serverlessapplicationrepository_cloudformation_stack.secrets_rotator_stack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/serverlessapplicationrepository_cloudformation_stack) | resource |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_serverlessapplicationrepository_application.secrets_rotator_application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/serverlessapplicationrepository_application) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | n/a | `string` | n/a | yes |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | n/a | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the environment. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace or Project name of the environment | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of already existing private subnets. | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of already existing public subnets. | `list(string)` | n/a | yes |
| <a name="input_secret_id"></a> [secret\_id](#input\_secret\_id) | n/a | `string` | `""` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage of the environment. | `string` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->