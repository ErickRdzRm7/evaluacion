resource "aws_cloudwatch_log_group" "monitoring_log_group" {
  name              = "/ecs/${var.app_name}/monitoring"
  retention_in_days = 14
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_usage" {
  alarm_name          = "${var.app_name}-high-cpu-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.period
  statistic           = "Average"
  threshold           = var.cpu_threshold

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_description         = "Alarm when CPU usage exceeds ${var.cpu_threshold}%"
  alarm_actions             = [] # o tu SNS ARN si lo tienes
  insufficient_data_actions = []
}
