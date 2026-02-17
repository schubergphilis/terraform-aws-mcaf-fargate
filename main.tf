locals {
  load_balancer = var.load_balancer_subnet_ids != null ? { create : true } : null

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

  efs_name = "${var.name}-efs"

  efs_tags = merge(var.tags, { "Name" = local.efs_name })

  updated_mount_points = [
    for mount in var.efs_mount_points :
    {
      sourceVolume  = local.efs_name
      containerPath = mount.containerPath
    }
  ]

  container_definition = {
    name                   = "app-${var.name}"
    command                = length(var.command) > 0 ? var.command : null
    image                  = var.image
    cpu                    = var.cpu
    memory                 = var.memory
    environment            = local.environment
    entryPoint             = length(var.entrypoint) > 0 ? var.entrypoint : null
    secrets                = local.secrets
    readonlyRootFilesystem = var.readonly_root_filesystem
    mountPoints            = local.updated_mount_points
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.default.name
        awslogs-region        = data.aws_region.current.region
        awslogs-stream-prefix = "ecs"
      }
    }
    portMappings = [
      {
        containerPort = var.port
        hostPort      = var.port
      }
    ]
  }
}

data "aws_region" "current" {
  region = var.region
}

module "task_execution_role" {
  source  = "schubergphilis/mcaf-role/aws"
  version = "~> 0.5.3"

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
  region            = var.region
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_id
  tags              = var.tags
}

resource "aws_ecs_task_definition" "default" {
  #checkov:skip=CKV_AWS_249:We argue its not necessary to split up task_role_arn & execution_role_arn since in this case it's not adding much security or maintainability benefits
  region                   = var.region
  family                   = var.name
  execution_role_arn       = module.task_execution_role.arn
  task_role_arn            = module.task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = [var.service_launch_type]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = jsonencode([local.container_definition])

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = upper(var.architecture)
  }

  dynamic "volume" {
    for_each = var.enable_efs ? [1] : []

    content {
      name = local.efs_name
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
  #checkov:skip=CKV_AWS_382: No problem with outgoing traffic to the internet
  region      = var.region
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
      security_groups = var.protocol != "TCP" ? [aws_security_group.lb[0].id] : null
      cidr_blocks     = var.protocol == "TCP" ? var.cidr_blocks : null
    }
  }

  #checkov:skip=CKV_AWS_382:Ensure no security groups allow egress from 0.0.0.0:0 to port -1
  egress {
    description = "Allow all outgoing traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [description]
  }
}

resource "aws_ecs_cluster" "default" {
  region = var.region
  name   = var.name
  tags   = var.tags

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
}

resource "aws_ecs_capacity_provider" "default" {
  count = var.capacity_provider_asg_arn != null ? 1 : 0

  region = var.region
  name   = "${var.name}-capacity-provider"

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
  count = var.capacity_provider_asg_arn != null ? 1 : 0

  region             = var.region
  capacity_providers = [aws_ecs_capacity_provider.default[*].name]
  cluster_name       = aws_ecs_cluster.default.name

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.default[*].name
  }
}

resource "aws_ecs_service" "default" {
  count = var.desired_count != null ? 1 : 0
  name  = var.name

  region                            = var.region
  cluster                           = aws_ecs_cluster.default.id
  enable_execute_command            = var.enable_execute_command
  task_definition                   = aws_ecs_task_definition.default.arn
  desired_count                     = var.desired_count
  launch_type                       = var.service_launch_type
  propagate_tags                    = "TASK_DEFINITION"
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.ecs_subnet_ids
    assign_public_ip = var.service_launch_type == "FARGATE" ? var.public_ip : false
  }

  dynamic "load_balancer" {
    for_each = aws_lb.default

    content {
      target_group_arn = aws_lb_target_group.default[0].id
      container_name   = "app-${var.name}"
      container_port   = var.port
    }
  }
}

resource "aws_ecs_service" "scaling" {
  count = var.scale_up_action != null ? 1 : 0
  name  = var.name

  region                            = var.region
  cluster                           = aws_ecs_cluster.default.id
  enable_execute_command            = var.enable_execute_command
  task_definition                   = aws_ecs_task_definition.default.arn
  desired_count                     = var.scale_up_action.max_capacity
  launch_type                       = var.service_launch_type
  propagate_tags                    = "TASK_DEFINITION"
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = var.ecs_subnet_ids
    assign_public_ip = var.service_launch_type == "FARGATE" ? var.public_ip : false
  }

  dynamic "load_balancer" {
    for_each = aws_lb.default

    content {
      target_group_arn = aws_lb_target_group.default[0].id
      container_name   = "app-${var.name}"
      container_port   = var.port
    }
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  count = var.scale_up_action != null ? 1 : 0

  max_capacity       = var.scale_up_action.max_capacity
  min_capacity       = var.scale_up_action.min_capacity
  resource_id        = "service/${var.name}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  lifecycle {
    ignore_changes = [max_capacity, min_capacity]
  }
}

# Scale down to 2 agents at 8PM
resource "aws_appautoscaling_scheduled_action" "scale_down_tfc_agents" {
  count = var.scale_down_action != null ? 1 : 0

  name               = "scale-down-${var.name}"
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  schedule           = var.scale_down_cron
  timezone           = var.ecs_scaling_actions_timezone

  scalable_target_action {
    min_capacity = var.scale_down_action.min_capacity
    max_capacity = var.scale_down_action.max_capacity
  }
}

# Scale up to 25 agents at 6AM
resource "aws_appautoscaling_scheduled_action" "scale_up_tfc_agents" {
  count = var.scale_up_action != null ? 1 : 0

  name               = "scale-up-${var.name}"
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  schedule           = var.scale_up_cron
  timezone           = var.ecs_scaling_actions_timezone

  scalable_target_action {
    min_capacity = var.scale_up_action.min_capacity
    max_capacity = var.scale_up_action.max_capacity
  }
}
