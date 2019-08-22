# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.name}"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = var.log_group_name
  })
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}
