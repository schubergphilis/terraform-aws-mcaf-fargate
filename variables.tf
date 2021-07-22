variable "capacity_provider_asg_arn" {
  type        = string
  default     = null
  description = "ARN of Autoscaling Group for capacity provider."
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

variable "cpu" {
  type        = number
  default     = 1024
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Desired number of docker containers to run"
}

variable "ecs_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs assigned to ECS cluster"
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  default     = false
  description = "Enable cross-zone load balancing of the (network) load balancer"
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

variable "image" {
  type        = string
  description = "Docker image to run in the ECS cluster"
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

variable "memory" {
  type        = number
  default     = 2048
  description = "Fargate instance memory to provision (in MiB)"
}

variable "name" {
  type        = string
  description = "Name of the Fargate cluster"
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
  default     = "HTTP"
  description = "The target protocol"

  validation {
    condition     = contains(["HTTP", "TCP"], var.protocol)
    error_message = "Allowed values for protocol are \"HTTP\" or \"TCP\"."
  }
}

variable "public_ip" {
  type        = bool
  default     = false
  description = "Assign a public ip to the service"
}

variable "region" {
  type        = string
  default     = null
  description = "The region this fargate cluster should reside in, defaults to the region used by the callee"
}

variable "role_policy" {
  type        = string
  description = "The Policy document for the role"
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
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  description = "SSL Policy for the LB Listener"
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
