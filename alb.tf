resource "aws_security_group" "alb" {
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
  name            = var.name
  subnets         = var.public_subnet_ids
  security_groups = [aws_security_group.alb.id]
  tags            = var.tags

  timeouts {
    create = "20m"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.default.id
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
  name        = var.name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  tags        = var.tags

  health_check {
    interval            = 30
    timeout             = 3
    path                = var.health_check_path
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.default.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = aws_acm_certificate.fargate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.default.id
  }
}
