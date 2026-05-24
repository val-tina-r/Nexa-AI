terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

module "auth" {
  source = "./modules/auth"

  app_name              = var.app_name
  region                = var.region
  cognito_domain_prefix = var.cognito_domain_prefix

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  common_tags = var.common_tags
}


module "ai" {
  source = "./modules/ai"

  app_name   = var.app_name
  region     = var.region
  account_id = var.account_id
  partition  = var.partition

  documents_bucket_name = var.documents_bucket_name

  vector_bucket_name = var.vector_bucket_name
  vector_index_name  = var.vector_index_name

  embedding_model_id   = var.embedding_model_id
  embedding_dimensions = var.embedding_dimensions

  generation_model_id = var.generation_model_id

  enable_knowledge_base = var.enable_knowledge_base

  common_tags = var.common_tags
}


module "api" {
  source = "./modules/api"

  app_name = var.app_name
  region   = var.region

  api_name = "${var.app_name}-api"

  allowed_origins = var.allowed_origins

  cognito_issuer = module.auth.user_pool_issuer

  cognito_user_pool_client_id = module.auth.user_pool_client_id

  generation_model_id = var.generation_model_id

  knowledge_base_id = module.ai.knowledge_base_id

  lambda_source_dir = var.lambda_source_dir

  common_tags = var.common_tags
}