variable "app_name" {
  type        = string
  description = "Nombre lógico de la aplicación."
}

variable "bucket_name" {
  type        = string
  description = "Nombre del bucket privado del frontend."
}

variable "common_tags" {
  type        = map(string)
  description = "Etiquetas comunes."
}
