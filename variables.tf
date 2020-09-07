variable "name" {
  type        = string
  description = "Name of the Fargate cluster"
}

variable "cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR block to allow access to the LB"
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "Certificate ARN for the LB Listener"
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

variable "environment" {
  type        = map
  default     = {}
  description = "Environment variables defined in the docker container"
}

variable "secrets" {
  type        = map
  default     = {}
  description = "An object representing the secret to expose to the docker container"
}

variable "health_check" {
  type = object({
    healthy_threshold   = number,
    interval            = number,
    path                = string,
    unhealthy_threshold = number
  })
  default     = null
  description = "Health check settings for the container"
}

variable "image" {
  type        = string
  default     = "nginx:latest"
  description = "Docker image to run in the ECS cluster"
}

variable "memory" {
  type        = number
  default     = 2048
  description = "Fargate instance memory to provision (in MiB)"
}

variable "port" {
  type        = number
  default     = 3000
  description = "Port exposed by the docker image to redirect traffic to"
}

variable "protocol" {
  type        = string
  default     = "HTTP"
  description = "The target protocol"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs assigned to ESC cluster"
}

variable "public_ip" {
  type        = bool
  default     = false
  description = "Assign a public ip to the service"
}

variable "public_subnet_ids" {
  type        = list(string)
  default     = null
  description = "List of subnet IDs assigned to the LB"
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

variable "vpc_id" {
  type        = string
  description = "AWS vpc id"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}
