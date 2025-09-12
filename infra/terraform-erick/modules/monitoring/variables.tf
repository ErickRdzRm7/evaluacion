variable "app_name" {
  description = "Application name, used in resource naming"
  type        = string
}

variable "cluster_name" {
  description = "ECS Cluster name"
  type        = string
}

variable "service_name" {
  type    = string
  default = "default-service-name"
}

variable "cpu_threshold" {
  description = "CPU usage threshold for alarm"
  type        = number
  default     = 80
}

variable "evaluation_periods" {
  description = "Number of periods to evaluate alarm"
  type        = number
  default     = 2
}

variable "period" {
  description = "Alarm period in seconds"
  type        = number
  default     = 60
}
