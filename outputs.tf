output "name" {
  value       = var.name
  description = "Name of the fargate deployment"
}

output "hostname" {
  value       = aws_alb.main.dns_name
  description = "Hostname of the Application Loadbalancer"
}

output "security_group_id" {
  value       = aws_security_group.ecs_tasks.id
  description = "Security group id of the ECS task"
}

output "task_execution_role_arn" {
  value       = module.ecs_task_execution_role.arn
  description = "ARN of the execution role"
}
