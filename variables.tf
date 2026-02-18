variable "architecture" {
  type        = string
  default     = "x86_64"
  description = "Instruction set architecture of the Fargate instance"

  validation {
    condition     = contains(["arm64", "x86_64"], var.architecture)
    error_message = "Allowed values are \"arm64\" or \"x86_64\"."
  }
}

variable "capacity_provider_asg_arn" {
  type        = string
  default     = null
  description = "ARN of Autoscaling Group for capacity provider"
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "Certificate ARN for the LB Listener"
}

variable "cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR block to allow access to the LB"
}

variable "command" {
  type        = list(string)
  default     = []
  description = "The command to execute inside the container"
}

variable "cpu" {
  type        = number
  default     = 1024
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
}

variable "desired_count" {
  type        = number
  default     = null
  description = "Desired number of docker containers to run"

  validation {
    condition     = var.desired_count != null || var.scale_up_action != null
    error_message = "At least one of desired_count or scale_up_action must be provided."
  }
}

variable "ecs_scaling_actions_timezone" {
  type        = string
  default     = "Europe/Amsterdam"
  description = "ECS scaling actions timezone"
}

variable "ecs_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs assigned to ECS cluster"
}

variable "enable_execute_command" {
  type        = bool
  default     = false
  description = "Enable ECS Exec for the service"

  validation {
    condition     = !var.enable_execute_command || !var.readonly_root_filesystem
    error_message = "readonly_root_filesystem must be false when enable_execute_command is true"
  }
}

variable "enable_efs" {
  type        = bool
  default     = false
  description = "Enable EFS volume creation and attachment to the container"
}

variable "enable_container_insights" {
  type        = bool
  default     = true
  description = "Enable Cloudwatch Container Insights"
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  default     = false
  description = "Enable cross-zone load balancing of the (network) load balancer"
}

variable "entrypoint" {
  type        = list(string)
  default     = []
  description = "The entry point that's passed to the container"
}

variable "environment" {
  type        = map(string)
  default     = {}
  description = "Environment variables defined in the docker container"
}

variable "health_check" {
  type = object({
    healthy_threshold   = number,
    interval            = number,
    path                = string,
    unhealthy_threshold = number
  })
  default = {
    healthy_threshold   = 3,
    interval            = 30,
    path                = null,
    unhealthy_threshold = 3
  }
  description = "Health check settings for the container"
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown. Only valid for services configured to use load balancers."
  type        = number
  default     = null
}

variable "image" {
  type        = string
  description = "Docker image to run in the ECS cluster"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "The custom KMS key ARN used encryption of the Cloudwatch log group"
}

variable "load_balancer_deregistration_delay" {
  type        = number
  default     = 300
  description = "The amount of time before a target is deregistered when draining"
}

variable "load_balancer_eip" {
  type        = bool
  default     = false
  description = "Whether to create Elastic IPs for the load balancer"
}

variable "load_balancer_internal" {
  type        = bool
  default     = false
  description = "Set to true to create an internal load balancer"
}

variable "load_balancer_subnet_ids" {
  type        = list(string)
  default     = null
  description = "List of subnet IDs assigned to the LB"
}

variable "load_balancer_deletion_protection" {
  type        = bool
  default     = true
  description = "Set to true to enable deletion protection on the load balancer"
}

variable "load_balancer_logging" {
  type = object({
    s3_bucket_arn = string,
    enabled       = bool,
    prefix        = string
  })
  default = {
    s3_bucket_arn = null
    enabled       = false
    prefix        = null
  }
  description = "Access logs configuration for the load balancer"
}

variable "log_retention_days" {
  type        = number
  description = "The cloudwatch log group retention in days"
  default     = 365
}

variable "memory" {
  type        = number
  default     = 2048
  description = "Fargate instance memory to provision (in MiB)"
}

variable "efs_mount_points" {
  type = list(object({
    containerPath = string
  }))
  default     = []
  description = "The mount points for data volumes in your container. This parameter maps to Volumes in the --volume option to docker run"
}

variable "efs_posix_user" {
  type        = number
  default     = 1000
  description = "Posix uid needs to be mapped at EFS Access Point"
}

variable "efs_posix_group" {
  type        = number
  default     = 1000
  description = "Posix gid needs to be mapped at EFS Access Point"
}

variable "name" {
  type        = string
  description = "Name of the Fargate cluster"
}

variable "permissions_boundary" {
  type        = string
  default     = null
  description = "The permissions boundary to set to TaskExecutionRole"
}

variable "port" {
  type        = number
  default     = 3000
  description = "Port exposed by the docker image to redirect traffic to"
}

variable "postfix" {
  type        = bool
  default     = false
  description = "Postfix the role and policy names with Role and Policy"
}

variable "protocol" {
  type        = string
  default     = null
  description = "The target protocol"

  validation {
    condition     = (var.protocol == null ? true : contains(["HTTP", "TCP"], var.protocol))
    error_message = "Allowed values for protocol are null, \"HTTP\" or \"TCP\"."
  }
}

variable "public_ip" {
  type        = bool
  default     = false
  description = "Assign a public ip to the service"
}

variable "operating_system_family" {
  type        = string
  default     = "LINUX"
  description = "The operating system family of the Fargate instance"

  validation {
    condition     = contains(["LINUX", "WINDOWS_SERVER_2019_FULL", "WINDOWS_SERVER_2019_CORE", "WINDOWS_SERVER_2022_FULL", "WINDOWS_SERVER_2022_CORE"], var.operating_system_family)
    error_message = "Allowed values are \"LINUX\", \"WINDOWS_SERVER_2019_FULL\", \"WINDOWS_SERVER_2019_CORE\", \"WINDOWS_SERVER_2022_FULL\", or \"WINDOWS_SERVER_2022_CORE\"."
  }
}

variable "readonly_root_filesystem" {
  type        = bool
  default     = true
  description = "When this parameter is true, the container is given read-only access to its root file system"
}

variable "region" {
  type        = string
  default     = null
  description = "The AWS region where resources will be created; if omitted the default provider region is used"
}

variable "role_policy" {
  type        = string
  description = "The Policy document for the role"
}

variable "scale_up_action" {
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default     = null
  description = "Desired number of docker containers to run during work hours if scheduled scaling is used"
}

variable "scale_down_action" {
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default     = null
  description = "Desired number of docker containers to run during off hours if scheduled scaling is used"
}

variable "scale_up_cron" {
  type        = string
  default     = "cron(0 6 ? * MON-FRI *)" # 6 AM every weekday
  description = "Cron for scale up scheduled action"
}

variable "scale_down_cron" {
  type        = string
  default     = "cron(0 20 * * ? *)" # 8 PM every day
  description = "Cron for scale down scheduled action"
}

variable "secrets" {
  type        = map(string)
  default     = {}
  description = "Map containing secrets to expose to the docker container"
}

variable "service_launch_type" {
  type        = string
  default     = "FARGATE"
  description = "The service launch type: either FARGATE or EC2"

  validation {
    condition     = contains(["FARGATE", "EC2"], var.service_launch_type)
    error_message = "Allowed values for service_launch_type are \"FARGATE\", or \"EC2\"."
  }
}

variable "ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  description = "SSL Policy for the LB Listener"

  validation {
    condition     = contains(["ELBSecurityPolicy-TLS13-1-2-2021-06", "ELBSecurityPolicy-TLS13-1-2-FIPS-2023-04", "ELBSecurityPolicy-TLS13-1-3-2021-06", "ELBSecurityPolicy-TLS13-1-3-FIPS-2023-04", "ELBSecurityPolicy-TLS13-1-2-Res-2021-06", "ELBSecurityPolicy-TLS13-1-2-Res-FIPS-2023-04"], var.ssl_policy)
    error_message = "Allowed values for ssl_policy are \"ELBSecurityPolicy-TLS13-1-2-2021-06\", \"ELBSecurityPolicy-TLS13-1-2-FIPS-2023-04\", \"ELBSecurityPolicy-TLS13-1-3-2021-06\", \"ELBSecurityPolicy-TLS13-1-3-FIPS-2023-04\", \"ELBSecurityPolicy-TLS13-1-2-Res-2021-06\" or \"ELBSecurityPolicy-TLS13-1-2-Res-FIPS-2023-04\"."
  }
}

variable "subdomain" {
  type = object({
    name    = string,
    zone_id = string
  })
  default     = null
  description = "The DNS subdomain and zone ID for the LB"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resources"
}

variable "target_group_stickiness" {
  type        = bool
  default     = false
  description = "Whether to bind a client’s session to a specific instance within the target group"
}

variable "vpc_id" {
  type        = string
  description = "AWS vpc id"
}
