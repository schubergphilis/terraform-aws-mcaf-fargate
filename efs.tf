resource "aws_efs_file_system" "default" {
  count      = var.enable_efs ? 1 : 0
  encrypted  = true
  kms_key_id = var.kms_key_id
  tags       = var.tags
}

resource "aws_efs_mount_target" "mount" {
  count           = var.enable_efs ? length(var.ecs_subnet_ids) : 0
  file_system_id  = aws_efs_file_system.default[0].id
  subnet_id       = var.ecs_subnet_ids[count.index]
  security_groups = [aws_security_group.allow_efs_mount[0].id]
}

resource "aws_efs_access_point" "default" {
  count          = var.enable_efs ? 1 : 0
  file_system_id = aws_efs_file_system.default[0].id
}

resource "aws_security_group" "allow_efs_mount" {
  count       = var.enable_efs ? 1 : 0
  name        = "${var.name}-efs-transit-encryption"
  description = "Allow mounting for EFS volume"
  vpc_id      = var.vpc_id

  ingress {
    description = "EFS transit encryption port"
    protocol    = "tcp"
    from_port   = 2999
    to_port     = 2999
    cidr_blocks = var.cidr_blocks #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  }

  ingress { # fails to mount if not added
    description = "Standard EFS port"
    protocol    = "tcp"
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = var.cidr_blocks #tfsec:ignore:aws-vpc-no-public-ingress-sgr
  }
}
