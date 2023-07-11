resource "aws_efs_file_system" "default" {
  count = var.enable_efs ? 1 : 0
  tags  = var.tags
}

resource "aws_efs_mount_target" "mount" {
  count          = var.enable_efs ? 1 : 0
  file_system_id = aws_efs_file_system.default[0].id
  subnet_id      = var.ecs_subnet_ids
  tags           = var.tags
}

resource "aws_efs_access_point" "default" {
  count          = var.enable_efs ? 1 : 0
  file_system_id = aws_efs_file_system.default[0].id
}
