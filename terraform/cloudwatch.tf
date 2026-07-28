resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${local.name_prefix}-backend"
  retention_in_days = 7

  tags = {
    Name = "${local.name_prefix}-backend-logs"
  }
}