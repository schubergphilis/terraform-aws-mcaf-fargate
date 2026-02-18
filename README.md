# terraform-aws-mcaf-fargate

Terraform module to create an ECS Fargate cluster with an Application Load Balancer and EFS volume (optional).

IMPORTANT: We do not pin modules to versions in our examples. We highly recommend that in your code you pin the version to the exact version you are using so that your infrastructure remains stable.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_task_execution_role"></a> [task\_execution\_role](#module\_task\_execution\_role) | schubergphilis/mcaf-role/aws | ~> 0.5.3 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_appautoscaling_scheduled_action.scale_down_tfc_agents](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_scheduled_action.scale_up_tfc_agents](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_scheduled_action) | resource |
| [aws_appautoscaling_target.ecs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_capacity_provider.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider) | resource |
| [aws_ecs_cluster.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.scaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_efs_access_point.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_backup_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_backup_policy) | resource |
| [aws_efs_file_system.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.mount](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_eip.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_role_policy_attachment.task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.allow_efs_mount](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecs_subnet_ids"></a> [ecs\_subnet\_ids](#input\_ecs\_subnet\_ids) | List of subnet IDs assigned to ECS cluster | `list(string)` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Docker image to run in the ECS cluster | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Fargate cluster | `string` | n/a | yes |
| <a name="input_role_policy"></a> [role\_policy](#input\_role\_policy) | The Policy document for the role | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | AWS vpc id | `string` | n/a | yes |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Instruction set architecture of the Fargate instance | `string` | `"x86_64"` | no |
| <a name="input_capacity_provider_asg_arn"></a> [capacity\_provider\_asg\_arn](#input\_capacity\_provider\_asg\_arn) | ARN of Autoscaling Group for capacity provider | `string` | `null` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | Certificate ARN for the LB Listener | `string` | `null` | no |
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | CIDR block to allow access to the LB | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_command"></a> [command](#input\_command) | The command to execute inside the container | `list(string)` | `[]` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | Fargate instance CPU units to provision (1 vCPU = 1024 CPU units) | `number` | `1024` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired number of docker containers to run | `number` | `null` | no |
| <a name="input_ecs_scaling_actions_timezone"></a> [ecs\_scaling\_actions\_timezone](#input\_ecs\_scaling\_actions\_timezone) | ECS scaling actions timezone | `string` | `"Europe/Amsterdam"` | no |
| <a name="input_efs_mount_points"></a> [efs\_mount\_points](#input\_efs\_mount\_points) | The mount points for data volumes in your container. This parameter maps to Volumes in the --volume option to docker run | <pre>list(object({<br/>    containerPath = string<br/>  }))</pre> | `[]` | no |
| <a name="input_efs_posix_group"></a> [efs\_posix\_group](#input\_efs\_posix\_group) | Posix gid needs to be mapped at EFS Access Point | `number` | `1000` | no |
| <a name="input_efs_posix_user"></a> [efs\_posix\_user](#input\_efs\_posix\_user) | Posix uid needs to be mapped at EFS Access Point | `number` | `1000` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | Enable Cloudwatch Container Insights | `bool` | `true` | no |
| <a name="input_enable_cross_zone_load_balancing"></a> [enable\_cross\_zone\_load\_balancing](#input\_enable\_cross\_zone\_load\_balancing) | Enable cross-zone load balancing of the (network) load balancer | `bool` | `false` | no |
| <a name="input_enable_efs"></a> [enable\_efs](#input\_enable\_efs) | Enable EFS volume creation and attachment to the container | `bool` | `false` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Enable ECS Exec for the service | `bool` | `false` | no |
| <a name="input_entrypoint"></a> [entrypoint](#input\_entrypoint) | The entry point that's passed to the container | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment variables defined in the docker container | `map(string)` | `{}` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | Health check settings for the container | <pre>object({<br/>    healthy_threshold   = number,<br/>    interval            = number,<br/>    path                = string,<br/>    unhealthy_threshold = number<br/>  })</pre> | <pre>{<br/>  "healthy_threshold": 3,<br/>  "interval": 30,<br/>  "path": null,<br/>  "unhealthy_threshold": 3<br/>}</pre> | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown. Only valid for services configured to use load balancers. | `number` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The custom KMS key ARN used encryption of the Cloudwatch log group | `string` | `null` | no |
| <a name="input_load_balancer_deletion_protection"></a> [load\_balancer\_deletion\_protection](#input\_load\_balancer\_deletion\_protection) | Set to true to enable deletion protection on the load balancer | `bool` | `true` | no |
| <a name="input_load_balancer_deregistration_delay"></a> [load\_balancer\_deregistration\_delay](#input\_load\_balancer\_deregistration\_delay) | The amount of time before a target is deregistered when draining | `number` | `300` | no |
| <a name="input_load_balancer_eip"></a> [load\_balancer\_eip](#input\_load\_balancer\_eip) | Whether to create Elastic IPs for the load balancer | `bool` | `false` | no |
| <a name="input_load_balancer_internal"></a> [load\_balancer\_internal](#input\_load\_balancer\_internal) | Set to true to create an internal load balancer | `bool` | `false` | no |
| <a name="input_load_balancer_logging"></a> [load\_balancer\_logging](#input\_load\_balancer\_logging) | Access logs configuration for the load balancer | <pre>object({<br/>    s3_bucket_arn = string,<br/>    enabled       = bool,<br/>    prefix        = string<br/>  })</pre> | <pre>{<br/>  "enabled": false,<br/>  "prefix": null,<br/>  "s3_bucket_arn": null<br/>}</pre> | no |
| <a name="input_load_balancer_subnet_ids"></a> [load\_balancer\_subnet\_ids](#input\_load\_balancer\_subnet\_ids) | List of subnet IDs assigned to the LB | `list(string)` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | The cloudwatch log group retention in days | `number` | `365` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Fargate instance memory to provision (in MiB) | `number` | `2048` | no |
| <a name="input_operating_system_family"></a> [operating\_system\_family](#input\_operating\_system\_family) | The operating system family of the Fargate instance | `string` | `"LINUX"` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | The permissions boundary to set to TaskExecutionRole | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | Port exposed by the docker image to redirect traffic to | `number` | `3000` | no |
| <a name="input_postfix"></a> [postfix](#input\_postfix) | Postfix the role and policy names with Role and Policy | `bool` | `false` | no |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | The target protocol | `string` | `null` | no |
| <a name="input_public_ip"></a> [public\_ip](#input\_public\_ip) | Assign a public ip to the service | `bool` | `false` | no |
| <a name="input_readonly_root_filesystem"></a> [readonly\_root\_filesystem](#input\_readonly\_root\_filesystem) | When this parameter is true, the container is given read-only access to its root file system | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where resources will be created; if omitted the default provider region is used | `string` | `null` | no |
| <a name="input_scale_down_action"></a> [scale\_down\_action](#input\_scale\_down\_action) | Desired number of docker containers to run during off hours if scheduled scaling is used | <pre>object({<br/>    min_capacity = number<br/>    max_capacity = number<br/>  })</pre> | `null` | no |
| <a name="input_scale_down_cron"></a> [scale\_down\_cron](#input\_scale\_down\_cron) | Cron for scale down scheduled action | `string` | `"cron(0 20 * * ? *)"` | no |
| <a name="input_scale_up_action"></a> [scale\_up\_action](#input\_scale\_up\_action) | Desired number of docker containers to run during work hours if scheduled scaling is used | <pre>object({<br/>    min_capacity = number<br/>    max_capacity = number<br/>  })</pre> | `null` | no |
| <a name="input_scale_up_cron"></a> [scale\_up\_cron](#input\_scale\_up\_cron) | Cron for scale up scheduled action | `string` | `"cron(0 6 ? * MON-FRI *)"` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map containing secrets to expose to the docker container | `map(string)` | `{}` | no |
| <a name="input_service_launch_type"></a> [service\_launch\_type](#input\_service\_launch\_type) | The service launch type: either FARGATE or EC2 | `string` | `"FARGATE"` | no |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | SSL Policy for the LB Listener | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| <a name="input_subdomain"></a> [subdomain](#input\_subdomain) | The DNS subdomain and zone ID for the LB | <pre>object({<br/>    name    = string,<br/>    zone_id = string<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_target_group_stickiness"></a> [target\_group\_stickiness](#input\_target\_group\_stickiness) | Whether to bind a client’s session to a specific instance within the target group | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The ARN of the ECS cluster |
| <a name="output_ecs_service_arn"></a> [ecs\_service\_arn](#output\_ecs\_service\_arn) | The ARN of the ECS service |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | FQDN of the route53 endpoint |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Hostname of the Application load balancer |
| <a name="output_http_listener_arn"></a> [http\_listener\_arn](#output\_http\_listener\_arn) | The ARN of the HTTP listener |
| <a name="output_https_listener_arn"></a> [https\_listener\_arn](#output\_https\_listener\_arn) | The ARN of the HTTPS listener |
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | The ARN of the load balancer |
| <a name="output_load_balancer_eips"></a> [load\_balancer\_eips](#output\_load\_balancer\_eips) | The Elastic IPs of the load balancer |
| <a name="output_name"></a> [name](#output\_name) | Name of the fargate deployment |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID of the ECS task |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | The ARN of the Target Group |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | ARN of the task definition |
| <a name="output_task_execution_role_arn"></a> [task\_execution\_role\_arn](#output\_task\_execution\_role\_arn) | ARN of the execution role |
| <a name="output_tcp_listener_arn"></a> [tcp\_listener\_arn](#output\_tcp\_listener\_arn) | The ARN of the TCP listener |
<!-- END_TF_DOCS -->

## Licensing

100% Open Source and licensed under the Apache License Version 2.0. See [LICENSE](https://github.com/schubergphilis/terraform-aws-mcaf-fargate/blob/master/LICENSE) for full details.
