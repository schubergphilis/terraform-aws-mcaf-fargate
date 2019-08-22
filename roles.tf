module "ecs_task_execution_role" {
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.1.3"
  name                  = var.name
  principal_type        = "Service"
  principal_identifiers = ["ecs-tasks.amazonaws.com"]
  role_policy           = var.role_policy
  tags                  = var.tags
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = module.ecs_task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
