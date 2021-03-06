locals {
  load_balancer = var.load_balancer_subnet_ids != null ? { create : true } : {}
  region        = var.region != null ? var.region : data.aws_region.current.name

  environment = [
    for k, v in var.environment :
    {
      name  = k
      value = v
    }
  ]

  secrets = [
    for k, v in var.secrets :
    {
      name  = k
      value = v
    }
  ]
}

data "aws_region" "current" {}

module "task_execution_role" {
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.0"
  name                  = "TaskExecutionRole-${var.name}"
  create_policy         = true
  principal_type        = "Service"
  principal_identifiers = ["ecs-tasks.amazonaws.com"]
  role_policy           = var.role_policy
  postfix               = var.postfix
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = module.task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/${var.name}"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_ecs_task_definition" "default" {
  family                   = var.name
  execution_role_arn       = module.task_execution_role.arn
  task_role_arn            = module.task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = [var.service_launch_type]
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = templatefile("${path.module}/templates/container_definition.tpl", {
    name        = var.name
    image       = var.image
    port        = var.port
    cpu         = var.cpu
    memory      = var.memory
    log_group   = aws_cloudwatch_log_group.default.name
    environment = jsonencode(local.environment)
    secrets     = jsonencode(local.secrets)
    region      = local.region
  })

  tags = var.tags
}

resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs"
  description = "Allow access to and from the ECS cluster"
  vpc_id      = var.vpc_id
  tags        = var.tags

  dynamic "ingress" {
    for_each = local.load_balancer

    content {
      protocol        = "tcp"
      from_port       = var.port
      to_port         = var.port
      security_groups = var.protocol != "TCP" ? [aws_security_group.lb.0.id] : null
      cidr_blocks     = var.protocol == "TCP" ? var.cidr_blocks : null
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS009
  }

  lifecycle {
    ignore_changes = [description]
  }
}

resource "aws_ecs_cluster" "default" {
  name = var.name
  tags = var.tags
}

resource "aws_ecs_service" "default" {
  name            = var.name
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.default.arn
  desired_count   = var.desired_count
  launch_type     = var.service_launch_type

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.ecs_subnet_ids
    assign_public_ip = var.service_launch_type == "FARGATE" ? var.public_ip : false
  }

  dynamic "load_balancer" {
    for_each = local.load_balancer

    content {
      target_group_arn = aws_lb_target_group.default.0.id
      container_name   = "app-${var.name}"
      container_port   = var.port
    }
  }
}
