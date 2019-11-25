output "name" {
  value       = var.name
  description = "Name of the fargate deployment"
}

output "fqdn" {
  value       = aws_route53_record.fargate.fqdn
  description = "FQDN of the route53 endpoint"
}

output "hostname" {
  value       = aws_alb.default.dns_name
  description = "Hostname of the Application Loadbalancer"
}

output "security_group_id" {
  value       = aws_security_group.ecs.id
  description = "Security group ID of the ECS task"
}

output "task_execution_role_arn" {
  value       = module.task_execution_role.arn
  description = "ARN of the execution role"
}
