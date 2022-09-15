# Terraform AWS Aurora/RDS module

This module represents a database setup which supports mysql and postgres in the flavor of aurora and non aurora.

Additional features like alerting, password-rotation and debugging via bastion host can be enabled.

## Prerequisites 

Basic VPC Product needs to be installed from service catalog hub.
See: https://eu-central-1.console.aws.amazon.com/servicecatalog/home?region=eu-central-1#products/prod-x66wyrky7zsaa

VPC-Ids needs to be passed to the module.

## Deployment Using Examples

The deployment can already be tried out from within the `examples` folder.

    terraform init
    terraform plan
    terraform apply

## Database Usage

### Connecting / Debugging

#### Via SSH-Tunnel

For debugging purposes the bastion host can be enabled by `enable_bastion_host` variable.
This will run an ec2 instance, which can be used as jump host to connect to the database located in the 
private network. If enabled, terraform will also create a `connect.sh` script.

    usage: connect.sh
      --sshtunnel         - uses ssh tunnel only (needs a public accessible ssh port opened)
      --sessionmanager    - uses ssh tunnel via sessionmanager websocket (does not need any public accessible port) 

By default the ec2 instance is part of the public network. 
The sshtunnel is secured by a short living ssh key and by the aws session token.

Beware - bastion has a security group with port 22 open to 0.0.0.0

After the tunnel/session has been opened, the database can be access by:
    
    mysql -P 3307 -uroot -p

In this case, the ssh tunnel will not use the default port, to not being blocked by a local mysql installation.

The password is being stored in the secrets-manager.


#### Via SessionsManager and IAM Role

Before you can connect, you need to create the a database user using AWSAuthenticationPlugin.

    CREATE USER dbuser IDENTIFIED WITH AWSAuthenticationPlugin as 'RDS';
    select user,plugin,host from mysql.user where user like '%dbuser%';
    GRANT USAGE ON *.* TO 'dbuser'@'%' REQUIRE SSL;
    GRANT ALL PRIVILEGES ON dbname.* TO 'dbuser'@'%';
    show grants for dbuser;

Now you can connect to Aurora using IAM Role

    RDSHOST=rds-default.cluster-czuqyweho66p.eu-central-1.rds.amazonaws.com
    TOKEN=$(aws rds generate-db-auth-token --hostname $RDSHOST --port 3306 --username dbuser --region eu-central-1)
    mysql -h 127.0.0.1 -P 3307 -u dbuser --password=$TOKEN

In this case, the ssh tunnel will not use the default port, to not being blocked by a local mysql installation.

## Security - Password Rotation

Password rotation can be enabled by `enable_password_rotation` variable. It just rotates the root user credentials.

The lambda function will be installed from the aws serverless repository and uses one of the following sources, depending on 
the database engine.

    "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSMySQLRotationSingleUser"
    "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSPostgreSQLRotationSingleUser"

## Monitoring & Alerting

Alerting can be connected to ms teams channel. 
See: https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook#create-incoming-webhook-1
to configure your channel.

The webhook url has to be passed to the module. See `ms_teams_webhook_url`.
For the `github` actions pipeline `TF_VAR_MS_TEAMS_WEBHOOK_URL` needs to be set.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.3 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.1.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >= 2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aurora"></a> [aurora](#module\_aurora) | ./modules/aurora | n/a |
| <a name="module_rds"></a> [rds](#module\_rds) | ./modules/rds | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_alarms"></a> [cluster\_alarms](#input\_cluster\_alarms) | Define metric based alerts for the cluster instances. | <pre>map(object({<br>    alarm_name          = string<br>    alarm_description   = string<br>    comparison_operator = string<br>    evaluation_periods  = number<br>    threshold           = number<br>    namespace           = string<br>    statistic           = string<br>    period              = number<br>    treat_missing_data  = string<br>  }))</pre> | `{}` | no |
| <a name="input_db_instances"></a> [db\_instances](#input\_db\_instances) | definition of db instances | <pre>map(object({<br>    identifier          = string<br>    instance_class      = string<br>    publicly_accessible = bool<br>    promotion_tier      = number<br>    backup              = any #TODO: change it in the future to optional(any). At the moment it is an opt-in experiment!<br>  }))</pre> | n/a | yes |
| <a name="input_enable_alerting"></a> [enable\_alerting](#input\_enable\_alerting) | n/a | `bool` | `false` | no |
| <a name="input_enable_bastion_host"></a> [enable\_bastion\_host](#input\_enable\_bastion\_host) | Set to `true` to allow the module to create any resources for the ec2 bastion host. | `bool` | `false` | no |
| <a name="input_enable_password_rotation"></a> [enable\_password\_rotation](#input\_enable\_password\_rotation) | n/a | `bool` | `false` | no |
| <a name="input_instance_alarms"></a> [instance\_alarms](#input\_instance\_alarms) | Define metric based alerts for the cluster instances. | <pre>map(object({<br>    alarm_name          = string<br>    alarm_description   = string<br>    comparison_operator = string<br>    evaluation_periods  = number<br>    threshold           = number<br>    namespace           = string<br>    statistic           = string<br>    period              = number<br>    treat_missing_data  = string<br>  }))</pre> | `{}` | no |
| <a name="input_is_aurora"></a> [is\_aurora](#input\_is\_aurora) | Activates aurora module. | `bool` | `true` | no |
| <a name="input_ms_teams_webhook_url"></a> [ms\_teams\_webhook\_url](#input\_ms\_teams\_webhook\_url) | URL for MS Teams Webhook. See: https://github.com/idealo/cloudwatch-alarm-to-ms-teams | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the environment. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace or Project name of the environment | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of already existing private subnets. | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of already existing public subnets. | `list(string)` | n/a | yes |
| <a name="input_rds_cluster_settings"></a> [rds\_cluster\_settings](#input\_rds\_cluster\_settings) | engine:             The database engine to use: postgres\|mysql<br>    engine\_version:     (Optional) The engine version to use. If auto\_minor\_version\_upgrade is enabled, you can provide a<br>                        prefix of the version such as 5.7 (for 5.7.10). The actual engine version used is returned in the<br>                        attribute engine\_version\_actual, see Attributes Reference below. For supported values, see the<br>                        EngineVersion parameter in API action CreateDBInstance. Note that for Amazon Aurora instances the<br>                        engine version must match the DB cluster's engine version'. Cannot be specified for a replica.<br>    cluster\_family:     The family of the DB parameter group<br>    enabled\_cloudwatch\_logs\_exports:<br>                        https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#enabled_cloudwatch_logs_exports<br>    db\_port:            The port to use for the db system<br>    cluster\_parameters: Additional cluster parameters.<br>    backup:             Backup configuration for aurora cluster. | <pre>object({<br>    engine                          = string<br>    engine_version                  = string<br>    cluster_family                  = string<br>    enabled_cloudwatch_logs_exports = list(string)<br>    db_port                         = number<br>    cluster_parameters = list(object({<br>      name         = string<br>      value        = string<br>      apply_method = string<br>    }))<br>    backup = any<br>  })</pre> | <pre>{<br>  "backup": null,<br>  "cluster_family": "aurora-postgresql14",<br>  "cluster_parameters": [<br>    {<br>      "apply_method": "immediate",<br>      "name": "timezone",<br>      "value": "Europe/Prague"<br>    }<br>  ],<br>  "db_port": 5432,<br>  "enabled_cloudwatch_logs_exports": [<br>    "postgresql"<br>  ],<br>  "engine": "aurora-postgresql",<br>  "engine_version": "14.3"<br>}</pre> | no |
| <a name="input_rds_instance_settings"></a> [rds\_instance\_settings](#input\_rds\_instance\_settings) | engine:           The database engine to use: postgres\|mysql<br>    engine\_version:   (Optional) The engine version to use. If auto\_minor\_version\_upgrade is enabled, you can provide a<br>                      prefix of the version such as 5.7 (for 5.7.10). The actual engine version used is returned in the<br>                      attribute engine\_version\_actual, see Attributes Reference below. For supported values, see the<br>                      EngineVersion parameter in API action CreateDBInstance. Note that for Amazon Aurora instances the<br>                      engine version must match the DB cluster's engine version'. Cannot be specified for a replica.<br>    family:           The family of the DB parameter group<br>    enabled\_cloudwatch\_logs\_exports:<br>                      https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#enabled_cloudwatch_logs_exports<br>    db\_port:          The port to use for the db system<br>    allocated\_storage:<br>                      The allocated storage in gigabytes<br>    max\_allocated\_storage:<br>                      Specifies the value for Storage Autoscaling<br>    db\_name:          The DB name to create. If omitted, no database is created initially<br>    username:         Username for the master DB user | <pre>object({<br>    engine                          = string<br>    engine_version                  = string<br>    major_engine_version            = string<br>    family                          = string<br>    enabled_cloudwatch_logs_exports = list(string)<br>    db_port                         = number<br>    allocated_storage               = number<br>    max_allocated_storage           = number<br>    db_name                         = string<br>    username                        = string<br>  })</pre> | <pre>{<br>  "allocated_storage": 20,<br>  "db_name": "replicaPostgresql",<br>  "db_port": 5432,<br>  "enabled_cloudwatch_logs_exports": [<br>    "postgresql",<br>    "upgrade"<br>  ],<br>  "engine": "postgres",<br>  "engine_version": "14.1",<br>  "family": "postgres14",<br>  "major_engine_version": "14",<br>  "max_allocated_storage": 100,<br>  "username": "replica_postgresql"<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"eu-central-1"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage of the environment. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id of an already existing vpc. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->