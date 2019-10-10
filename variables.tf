variable "name" {
  type        = string
  description = "Name of the Fargate cluster"
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Desired number of docker containers to run"
}

variable "cpu" {
  type        = number
  default     = 1024
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
}

variable "memory" {
  type        = number
  default     = 2048
  description = "Fargate instance memory to provision (in MiB)"
}

variable "image" {
  type        = string
  default     = "nginx:latest"
  description = "Docker image to run in the ECS cluster"
}

variable "environment" {
  type        = map
  default     = {}
  description = "Environment variables defined in the docker container"
}

variable "port" {
  type        = number
  default     = 3000
  description = "Port exposed by the docker image to redirect traffic to"
}

variable "role_policy" {
  type        = string
  description = "The Policy document for the role"
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

variable "cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "CIDR block to allow access to the ALB"

}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs assigned to the ALB"
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

variable "ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  description = "SSL Policy for the ALB Listener"
}

variable "certificate_arn" {
  type        = string
  description = "Certificate ARN for the ALB Listener"
}

variable "health_check_path" {
  type        = string
  default     = "/"
  description = "Path used to check the health of the container"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources"
}
