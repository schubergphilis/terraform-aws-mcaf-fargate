locals {
  alb_hostname        = local.load_balancer != null ? aws_alb.default[0].dns_name : null
  http_listener_arn   = local.load_balancer != null && var.protocol != "TCP" ? aws_alb_listener.http[0].arn : null
  https_listener_arn  = local.load_balancer != null && var.protocol != "TCP" ? aws_alb_listener.https[0].arn : null
  tcp_listener_arn    = local.load_balancer != null && var.protocol == "TCP" ? aws_alb_listener.tcp[0].arn : null
  target_group_arn    = local.load_balancer != null ? aws_alb_target_group.default[0].arn : null
  load_balancer_count = local.load_balancer != null ? 1 : 0
}

resource "aws_security_group" "alb" {
  count       = local.load_balancer_count
  name        = "${var.name}-alb"
  description = "Controls access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.cidr_blocks
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "default" {
  count           = local.load_balancer_count
  name            = var.name
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.alb[0].id]
  tags            = var.tags

  timeouts {
    create = "20m"
  }
}

resource "aws_alb_listener" "http" {
  count             = var.protocol == "TCP" ? 0 : local.load_balancer_count
  load_balancer_arn = aws_alb.default[0].id
  port              = 80
  protocol          = "HTTP"

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

resource "aws_alb_target_group" "default" {
  count       = local.load_balancer_count
  name        = var.name
  port        = var.port
  protocol    = var.protocol
  target_type = "ip"
  vpc_id      = var.vpc_id
  tags        = var.tags

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    interval            = 30
    timeout             = var.protocol != "TCP" ? 3 : null
    protocol            = var.protocol
    path                = var.protocol != "TCP" ? var.health_check_path : null
    matcher             = var.protocol != "TCP" ? 200 : null
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_alb_listener" "https" {
  count             = var.protocol == "TCP" ? 0 : local.load_balancer_count
  load_balancer_arn = aws_alb.default[0].id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = local.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.default[0].id
  }
}

resource "aws_alb_listener" "tcp" {
  count             = var.protocol == "TCP" ? 1 : 0
  load_balancer_arn = aws_alb.default[0].id
  port              = var.port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.default[0].id
  }
}
