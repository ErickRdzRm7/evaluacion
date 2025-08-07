output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.monitoring_log_group.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.monitoring_log_group.arn
}

output "high_cpu_alarm_name" {
  description = "Name of the high CPU usage CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.high_cpu_usage.alarm_name
}

output "high_cpu_alarm_arn" {
  description = "ARN of the high CPU usage CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.high_cpu_usage.arn
}
