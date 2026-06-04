variable "app_name" {
  type = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "partition" {
  type = string
  default = "aws"
}

variable "cognito_domain_prefix" {
  type = string
}

variable "callback_urls" {
  type = list(string)
}

variable "logout_urls" {
  type = list(string)
}

variable "allowed_origins" {
  type = list(string)
  
}

variable "documents_bucket_name" {
  type = string
}

variable "vector_bucket_name" {
  type = string
}

variable "vector_index_name" {
  type = string
}

variable "embedding_model_id" {
  type = string
}

variable "embedding_dimensions" {
  type = number
}

variable "generation_model_id" {
  type = string
}

variable "enable_knowledge_base" {
  type = bool
}

variable "lambda_source_dir" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "frontend_bucket_name" {
  description = "Nombre del bucket del frontend"
  type        = string
}
