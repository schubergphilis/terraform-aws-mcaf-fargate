variable "name" {
  type        = string
  description = "The name of the Fargate cluster"
}

variable "app_count" {
  default     = 1
  description = "Number of docker containers to run"
}

variable "app_image" {
  type        = string
  default     = "nginx:latest"
  description = "Docker image to run in the ECS cluster"
}

variable "app_port" {
  type        = number
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 3000
}

variable "certificate_arn" {
  type        = string
  description = "Certificate ARN for the ALB Listener"
}

variable "ssl_policy" {
  type        = string
  description = "SSL Policy for the ALB Listener"
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable "region" {
  type        = string
  default     = null
  description = "The region this fargate cluster should reside in, defaults to the region used by the callee"
}

variable "vpc_id" {
  type        = string
  description = "AWS vpc id"
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "fargate_cpu" {
  type        = string
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  type        = string
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "environment" {
  type        = map
  description = "Environment variables defined in the docker container"
  default     = {}
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "Ingress CIDR block to ALB"
  default     = ["0.0.0.0/0"]
}

variable "log_group_name" {
  type        = string
  description = "The name of the Log-group in Cloudtrail"
  default     = "log-group"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}

variable "role_policy" {
  type        = string
  description = "The Policy document for the role"
}
