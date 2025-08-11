variable app_name {
  type        = string
  default     = " EduAI"
  description = "The name of the application used in resource names."
}
variable "environment" {
  description = "Deployment environment"
  type        = string
}
