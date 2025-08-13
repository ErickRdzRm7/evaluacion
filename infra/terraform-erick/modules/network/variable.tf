variable "app_name" {
  type        = string
  description = "Application name"
}
variable "vpc_cidr" {
  type        = string
  default = "10.0.0.0/16"
  description = "CIDR block for VPC"
}
variable "app_subnet_cidr" {
  description = "Lista de bloques CIDR para las subredes de la aplicación"
  type        = list(string)
}
variable "availability_zones" {
  type        = list(string)
  description = "Lista de zonas de disponibilidad"
}
variable "private_subnet_cidrs" {
  type        = list(string)
   default = ["10.0.10.0/24", "10.0.11.0/24"]
  description = "CIDR blocks for private subnets"
}
variable "public_subnet_cidrs" {
  default = ["10.0.20.0/24", "10.0.21.0/24"]
}
