locals {
  access_logging      = var.load_balancer_logging.enabled ? { create = true } : {}
  lb_hostname         = local.load_balancer != null ? aws_lb.default[0].dns_name : null
  http_listener_arn   = local.load_balancer != null && var.protocol != "TCP" ? aws_lb_listener.http[0].arn : null
  https_listener_arn  = local.load_balancer != null && var.protocol != "TCP" ? aws_lb_listener.https[0].arn : null
  tcp_listener_arn    = local.load_balancer != null && var.protocol == "TCP" ? aws_lb_listener.tcp[0].arn : null
  load_balancer_count = local.load_balancer != null ? 1 : 0
  eip_subnets         = var.load_balancer_eip ? var.load_balancer_subnet_ids : []

  target_group_arn = local.load_balancer == null ? null : (
    length(aws_lb_target_group.default) > 0 ? aws_lb_target_group.default[0].arn : null
  )
}

resource "aws_security_group" "lb" {
  #checkov:skip=CKV2_AWS_5: False positive finding, the security group is attached.
  count       = var.protocol != "TCP" ? local.load_balancer_count : 0
  name        = "${var.name}-lb"
  description = "Controls access to the LB"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress {
    description = "HTTP ingress"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    #checkov:skip=CKV_AWS_260: Port 80 (HTTP) is redirected to 443 (HTTPS)
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    description = "HTTPS ingress"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.cidr_blocks
  }

  egress {
    description = "Public egress"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0

    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-vpc-no-public-egress-sgr
  }
}

resource "aws_eip" "lb" {
  #checkov:skip=CKV2_AWS_19:IP's can also be used for non-EC2 resources
  count = length(local.eip_subnets)

  domain = "vpc"
  tags   = var.tags
}

resource "aws_lb" "default" {
  #checkov:skip=CKV2_AWS_28:WAF not implemnted (yet)
  count                            = local.load_balancer_count
  name                             = var.name
  drop_invalid_header_fields       = var.protocol != "TCP" ? true : null
  internal                         = var.load_balancer_internal #tfsec:ignore:AWS005
  load_balancer_type               = var.protocol == "TCP" ? "network" : "application"
  enable_deletion_protection       = var.load_balancer_deletion_protection
  enable_cross_zone_load_balancing = var.protocol == "TCP" ? var.enable_cross_zone_load_balancing : false
  subnets                          = var.load_balancer_eip ? null : var.load_balancer_subnet_ids
  security_groups                  = var.protocol != "TCP" ? [aws_security_group.lb[0].id] : null
  tags                             = var.tags

  dynamic "access_logs" {
    for_each = local.access_logging

    content {
      bucket  = var.load_balancer_logging.s3_bucket_arn
      prefix  = var.load_balancer_logging.prefix
      enabled = var.load_balancer_logging.enabled
    }
  }

  dynamic "subnet_mapping" {
    for_each = [for subnet_id in local.eip_subnets : {
      subnet_id     = subnet_id
      allocation_id = aws_eip.lb[index(local.eip_subnets, subnet_id)].id
    }]

    content {
      subnet_id     = subnet_mapping.value.subnet_id
      allocation_id = subnet_mapping.value.allocation_id
    }
  }

  timeouts {
    create = "20m"
  }
}

resource "aws_lb_listener" "http" {
  count             = var.protocol == "TCP" ? 0 : local.load_balancer_count
  load_balancer_arn = aws_lb.default[0].id
  port              = 80
  protocol          = "HTTP"
  tags              = var.tags

  default_action {
    type = "redirect"

    redirect {
      host        = local.application_fqdn
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "default" {
  count                = local.load_balancer_count
  name                 = var.name
  deregistration_delay = var.load_balancer_deregistration_delay
  port                 = var.port
  protocol             = var.protocol
  target_type          = "ip"
  vpc_id               = var.vpc_id
  tags                 = var.tags

  health_check {
    interval            = var.health_check.interval
    timeout             = var.protocol != "TCP" ? 3 : null
    protocol            = var.protocol
    path                = var.protocol != "TCP" ? var.health_check.path : null
    matcher             = var.protocol != "TCP" ? 200 : null
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
  }

  stickiness {
    enabled = var.target_group_stickiness
    type    = var.protocol == "HTTP" ? "lb_cookie" : "source_ip"
  }
}

resource "aws_lb_listener" "https" {
  count             = var.protocol == "TCP" ? 0 : local.load_balancer_count
  load_balancer_arn = aws_lb.default[0].id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = local.certificate_arn
  tags              = var.tags

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[0].id
  }
}

resource "aws_lb_listener" "tcp" {
  count             = var.protocol == "TCP" ? 1 : 0
  load_balancer_arn = aws_lb.default[0].id
  port              = var.port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[0].id
  }
}
