output "name" {
  value       = var.name
  description = "The name of the fargate deployment"
}

output "alb_hostname" {
  value       = aws_alb.main.dns_name
  description = "The hostname of the Application Loadbalancer"
}

output "ecs_task_execution_role_arn" {
  value       = module.ecs_task_execution_role.arn
  description = "The ARN of the execution role"
}

output "ecs_security_group_id" {
  value       = aws_security_group.ecs_tasks.id
  description = "The security group id of the ECS task"
}
