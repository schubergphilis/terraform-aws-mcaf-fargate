locals {
  load_balancer = var.load_balancer_subnet_ids != null ? { create : true } : null
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
      name      = k
      valueFrom = v
    }
  ]

  updated_mount_points = [
    for mount in var.efs_mount_points :
    {
      sourceVolume  = "${var.name}-efs"
      containerPath = mount.containerPath
    }
  ]
}

data "aws_region" "current" {}

module "task_execution_role" {
  source                = "github.com/schubergphilis/terraform-aws-mcaf-role?ref=v0.3.3"
  name                  = "TaskExecutionRole-${var.name}"
  create_policy         = true
  principal_type        = "Service"
  principal_identifiers = ["ecs-tasks.amazonaws.com"]
  role_policy           = var.role_policy
  postfix               = var.postfix
  tags                  = var.tags
  permissions_boundary  = var.permissions_boundary
}

resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = module.task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/ecs/${var.name}"
  retention_in_days = 30
  kms_key_id        = var.kms_key_id
  tags              = var.tags
}

resource "aws_ecs_task_definition" "default" {
  #checkov:skip=CKV_AWS_249:We argue its not necessary to split up task_role_arn & execution_role_arn since in this case it's not adding much security or maintainability benefits
  family                   = var.name
  execution_role_arn       = module.task_execution_role.arn
  task_role_arn            = module.task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = [var.service_launch_type]
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = templatefile("${path.module}/templates/container_definition.tpl", {
    name                   = var.name
    image                  = var.image
    port                   = var.port
    cpu                    = var.cpu
    memory                 = var.memory
    mountPoints            = local.updated_mount_points
    log_group              = aws_cloudwatch_log_group.default.name
    environment            = jsonencode(local.environment)
    secrets                = jsonencode(local.secrets)
    readonlyRootFilesystem = var.readonly_root_filesystem
    region                 = local.region
  })

  dynamic "volume" {
    for_each = var.enable_efs ? [1] : []

    content {
      name = "${var.name}-efs"
      efs_volume_configuration {
        file_system_id          = aws_efs_file_system.default[0].id
        transit_encryption      = "ENABLED"
        transit_encryption_port = 2999
        authorization_config {
          access_point_id = aws_efs_access_point.default[0].id
          iam             = "ENABLED"
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs"
  description = "Allow access to and from the ECS cluster"
  vpc_id      = var.vpc_id
  tags        = var.tags

  dynamic "ingress" {
    for_each = aws_lb.default

    content {
      description     = "Allow access from the ECS cluster"
      protocol        = "tcp"
      from_port       = var.port
      to_port         = var.port
      security_groups = var.protocol != "TCP" ? [aws_security_group.lb.0.id] : null
      cidr_blocks     = var.protocol == "TCP" ? var.cidr_blocks : null
    }
  }

  egress {
    description = "Allow all outgoing traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  }

  lifecycle {
    ignore_changes = [description]
  }
}

resource "aws_ecs_cluster" "default" {
  name = var.name
  tags = var.tags

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
}

resource "aws_ecs_capacity_provider" "default" {
  count = var.capacity_provider_asg_arn != null ? 1 : 0
  name  = "${var.name}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.capacity_provider_asg_arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      instance_warmup_period = 60
      status                 = "ENABLED"
      target_capacity        = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "default" {
  count              = var.capacity_provider_asg_arn != null ? 1 : 0
  capacity_providers = [aws_ecs_capacity_provider.default[*].name]
  cluster_name       = aws_ecs_cluster.default.name

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.default[*].name
  }
}

resource "aws_ecs_service" "default" {
  name            = var.name
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.default.arn
  desired_count   = var.desired_count
  launch_type     = var.service_launch_type
  propagate_tags  = "TASK_DEFINITION"

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.ecs_subnet_ids
    assign_public_ip = var.service_launch_type == "FARGATE" ? var.public_ip : false
  }

  dynamic "load_balancer" {
    for_each = aws_lb.default

    content {
      target_group_arn = aws_lb_target_group.default.0.id
      container_name   = "app-${var.name}"
      container_port   = var.port
    }
  }
}
