output "monitoring_log_group_name" {
  value = module.monitoring.log_group_name
}

output "monitoring_high_cpu_alarm_arn" {
  value = module.monitoring.high_cpu_alarm_arn
}
