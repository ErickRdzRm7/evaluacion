variable "app_name" {}
variable "frontend_image" {}
variable "ecs_cluster_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "desired_count" {
  default = 1
}
variable "region" {}

variable "vpc_id" {
  description = "vpc from the project"
  type        = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "image_tag" {
  description = "La etiqueta de la imagen de Docker que Atlantis construyó."
  type        = string
}
