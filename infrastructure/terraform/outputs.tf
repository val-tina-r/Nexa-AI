output "api_endpoint" {
  value = module.api.api_endpoint
}

output "documents_bucket_name" {
  value = module.ai.documents_bucket_name
}

output "knowledge_base_id" {
  value = module.ai.knowledge_base_id
}

output "data_source_id" {
  value = module.ai.data_source_id
}

output "user_pool_id" {
  value = module.auth.user_pool_id
}

output "user_pool_client_id" {
  value = module.auth.user_pool_client_id
}

output "cognito_hosted_ui_domain" {
  value = module.auth.cognito_hosted_ui_domain
}