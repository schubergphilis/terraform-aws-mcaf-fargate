resource "aws_efs_file_system" "default" {
  count          = var.enable_efs ? 1 : 0
  encrypted      = true
  kms_key_id     = var.kms_key_id
  creation_token = local.efs_name
  tags           = local.efs_tags
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "EFS_Statement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite"
    ]

    resources = [aws_efs_file_system.default[0].arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "policy" {
  count          = var.enable_efs ? 1 : 0
  file_system_id = aws_efs_file_system.default[0].id
  policy         = data.aws_iam_policy_document.policy.json
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
  posix_user {
    gid = var.efs_posix_user
    uid = var.efs_posix_group
  }
  root_directory {
    creation_info {
      owner_gid   = var.efs_posix_user
      owner_uid   = var.efs_posix_group
      permissions = "0755"
    }
    # Setting a path is required for creation_info to ve valid.
    # It will be mounted as the root for that EFS Access Point,
    # so you won't actually see a /my-data folder in your ECS app.
    path = "/my-data"
  }
}

resource "aws_security_group" "allow_efs_mount" {
  count       = var.enable_efs ? 1 : 0
  name        = "${var.name}-efs-transit-encryption"
  description = "Allow mounting for EFS volume"
  vpc_id      = var.vpc_id

  ingress {
    description     = "EFS transit encryption port"
    protocol        = "tcp"
    from_port       = 2999
    to_port         = 2999
    security_groups = [aws_security_group.ecs.id]
  }

  ingress { # fails to mount if not added
    description     = "Standard EFS port"
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
    security_groups = [aws_security_group.ecs.id]
  }
}
