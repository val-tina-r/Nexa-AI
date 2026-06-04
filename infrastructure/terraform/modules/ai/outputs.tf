output "documents_bucket_name" {
  value = aws_s3_bucket.documents.id
}

output "documents_bucket_arn" {
  value = aws_s3_bucket.documents.arn
}

output "vector_bucket_arn" {
  value = local.vector_bucket_arn
}

output "vector_index_arn" {
  value = local.vector_index_arn
}

output "knowledge_base_id" {
  value = aws_bedrockagent_knowledge_base.kb[0].id
}

output "data_source_id" {
  value = aws_bedrockagent_data_source.documents[0].data_source_id
}
