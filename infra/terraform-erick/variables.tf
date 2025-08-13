variable "app_name" {
  type    = string
  default = "app"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}


variable "environment" {
  type    = string
  default = "development"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "app_subnet_cidr" {
  description = "Lista de CIDR para las subredes"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}


variable "availability_zones" {
  type    = list(string)
  default = ["us-east-2a", "us-east-2b"]
}


variable "cluster_name" {
  type    = string
  default = "app-cluster"
}

variable "ecs_sg_frontend" {
  type        = string
  description = "Security group for ECS frontend"
  default     = "ecs_sg_frontend"
}
