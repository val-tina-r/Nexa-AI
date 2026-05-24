variable "app_name" {
  type        = string
  description = "Nombre lógico de la aplicación."
}

variable "region" {
  type        = string
  description = "Región AWS."
}

variable "cognito_domain_prefix" {
  type        = string
  description = "Prefijo único del dominio Cognito Hosted UI."
}

variable "callback_urls" {
  type        = list(string)
  description = "URLs permitidas de callback OAuth."
}

variable "logout_urls" {
  type        = list(string)
  description = "URLs permitidas de logout OAuth."
}

variable "common_tags" {
  type        = map(string)
  description = "Etiquetas comunes."
}
