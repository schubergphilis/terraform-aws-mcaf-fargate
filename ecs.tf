locals {
  region = var.region != null ? var.region : data.aws_region.current.name
}

data "aws_region" "current" {}

resource "aws_ecs_cluster" "main" {
  name = var.name
  tags = var.tags
}

data "null_data_source" "environment" {
  count = length(var.environment)

  inputs = {
    name  = "${element(keys(var.environment), count.index)}"
    value = "${element(values(var.environment), count.index)}"
  }
}

data "template_file" "app" {
  template = file("${path.module}/templates/container_definition.tpl")
  vars = {
    name           = var.name
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    environment    = jsonencode(data.null_data_source.environment.*.outputs)
    region         = local.region
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.name
  execution_role_arn       = module.ecs_task_execution_role.arn
  task_role_arn            = module.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = data.template_file.app.rendered
}

resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "app-${var.name}"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.front_end_https, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
