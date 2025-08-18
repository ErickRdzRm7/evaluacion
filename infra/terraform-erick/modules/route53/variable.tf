variable "record_name" {
  description = "Nombre del registro DNS"
  type        = string
}

variable "record_type" {
  description = "Tipo de registro DNS"
  type        = string
}

variable "record_value" {
  description = "Valor del registro DNS (IP o CNAME)"
  type        = string
}

variable "zone_id" {
  description = "ID de la zona DNS en Route53"
  type        = string
}
