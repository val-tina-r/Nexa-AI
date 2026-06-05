variable "app_name" {
  type = string
  default = "nexa-ai"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "account_id" {
  type = string
  default = "253627982101"
}

variable "partition" {
  type = string
  default = "aws"
}

variable "cognito_domain_prefix" {
  type = string
  default = "nexa-ai-auth-g3"
}

variable "callback_urls" {
  type = list(string)
  default = [
    "http://localhost:3000",
    "http://localhost:3000/api/auth/callback/cognito"
  ]
}

variable "logout_urls" {
  type = list(string)
  default = [
    "http://localhost:3000"
  ]
}

variable "allowed_origins" {
  type = list(string)

  default = [
    "http://localhost:3000"
  ]
}

variable "documents_bucket_name" {
  type = string
  default = "nexa-ai-documents-g3"
}

variable "vector_bucket_name" {
  type = string
  default = "nexa-ai-vectors-g3"
}

variable "vector_index_name" {
  type = string
  default = "nexa-ai-vector-index"
}

variable "embedding_model_id" {
  type = string
  default = "amazon.titan-embed-text-v2:0"
}

variable "embedding_dimensions" {
  type = number
  default = 1024
}

variable "generation_model_id" {
  type = string
  default = "amazon.nova-lite-v1:0"
}

variable "enable_knowledge_base" {
  type = bool
  default = true
}

variable "lambda_source_dir" {
  type = string
  default = "../../app/backend/src/lambda"
}

variable "common_tags" {
  type = map(string)
  default = {
    Project     = "Nexa-AI"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

variable "frontend_bucket_name" {
  description = "Nombre del bucket del frontend"
  type        = string
  default     = "nexa-ai-frontend-g3"
}
