# terraform-aws-mcaf-fargate

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | >= 3.10 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.10 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ecs\_subnet\_ids | List of subnet IDs assigned to ECS cluster | `list(string)` | n/a | yes |
| image | Docker image to run in the ECS cluster | `string` | n/a | yes |
| name | Name of the Fargate cluster | `string` | n/a | yes |
| role\_policy | The Policy document for the role | `string` | n/a | yes |
| tags | A mapping of tags to assign to the resources | `map(string)` | n/a | yes |
| vpc\_id | AWS vpc id | `string` | n/a | yes |
| certificate\_arn | Certificate ARN for the LB Listener | `string` | `null` | no |
| cidr\_blocks | CIDR block to allow access to the LB | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| cpu | Fargate instance CPU units to provision (1 vCPU = 1024 CPU units) | `number` | `1024` | no |
| desired\_count | Desired number of docker containers to run | `number` | `1` | no |
| enable\_cross\_zone\_load\_balancing | Enable cross-zone load balancing of the (network) load balancer | `bool` | `false` | no |
| environment | Environment variables defined in the docker container | `map(string)` | `{}` | no |
| health\_check | Health check settings for the container | <pre>object({<br>    healthy_threshold   = number,<br>    interval            = number,<br>    path                = string,<br>    unhealthy_threshold = number<br>  })</pre> | <pre>{<br>  "healthy_threshold": 3,<br>  "interval": 30,<br>  "path": null,<br>  "unhealthy_threshold": 3<br>}</pre> | no |
| load\_balancer\_eip | Whether to create Elastic IPs for the load balancer | `bool` | `false` | no |
| load\_balancer\_internal | Set to true to create an internal load balancer | `bool` | `false` | no |
| load\_balancer\_subnet\_ids | List of subnet IDs assigned to the LB | `list(string)` | `null` | no |
| memory | Fargate instance memory to provision (in MiB) | `number` | `2048` | no |
| port | Port exposed by the docker image to redirect traffic to | `number` | `3000` | no |
| postfix | Postfix the role and policy names with Role and Policy | `bool` | `false` | no |
| protocol | The target protocol | `string` | `"HTTP"` | no |
| public\_ip | Assign a public ip to the service | `bool` | `false` | no |
| region | The region this fargate cluster should reside in, defaults to the region used by the callee | `string` | `null` | no |
| secrets | Map containing secrets to expose to the docker container | `map(string)` | `{}` | no |
| service\_launch\_type | The service launch type: either FARGATE or EC2 | `string` | `"FARGATE"` | no |
| ssl\_policy | SSL Policy for the LB Listener | `string` | `"ELBSecurityPolicy-TLS-1-2-Ext-2018-06"` | no |
| subdomain | The DNS subdomain and zone ID for the LB | <pre>object({<br>    name    = string,<br>    zone_id = string<br>  })</pre> | `null` | no |
| target\_group\_stickiness | Whether to bind a client’s session to a specific instance within the target group | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_arn | The ARN of the ECS cluster |
| fqdn | FQDN of the route53 endpoint |
| hostname | Hostname of the Application load balancer |
| http\_listener\_arn | The ARN of the HTTP listener |
| https\_listener\_arn | The ARN of the HTTPS listener |
| load\_balancer\_eips | The Elastic IPs of the load balancer |
| name | Name of the fargate deployment |
| security\_group\_id | Security group ID of the ECS task |
| target\_group\_arn | The ARN of the Target Group |
| task\_definition\_arn | ARN of the task definition |
| task\_execution\_role\_arn | ARN of the execution role |
| tcp\_listener\_arn | The ARN of the TCP listener |

<!--- END_TF_DOCS --->
