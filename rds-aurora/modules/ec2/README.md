<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.bastion_host_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.instance_connect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.logging_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.bastion_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.bastion_host_AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.logging_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.ec2_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.allow_ssh_pub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [local_file.connect_script](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_ami.amazon-linux-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [template_file.connect_script](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the environment. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace or Project name of the environment | `string` | n/a | yes |
| <a name="input_public_subnet"></a> [public\_subnet](#input\_public\_subnet) | n/a | `list(string)` | n/a | yes |
| <a name="input_rds_endpoint"></a> [rds\_endpoint](#input\_rds\_endpoint) | n/a | `string` | n/a | yes |
| <a name="input_rds_engine"></a> [rds\_engine](#input\_rds\_engine) | n/a | `string` | n/a | yes |
| <a name="input_rds_port"></a> [rds\_port](#input\_rds\_port) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_sg_rds_connect_id"></a> [sg\_rds\_connect\_id](#input\_sg\_rds\_connect\_id) | n/a | `any` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage of the environment. | `string` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_availability_zone"></a> [public\_availability\_zone](#output\_public\_availability\_zone) | n/a |
| <a name="output_public_instance_id"></a> [public\_instance\_id](#output\_public\_instance\_id) | n/a |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | n/a |
<!-- END_TF_DOCS -->