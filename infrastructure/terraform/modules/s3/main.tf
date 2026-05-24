# --------------------------------------------------------------------------
# Amazon S3 vectors Bucket
# --------------------------------------------------------------------------

resource "aws_s3_bucket" "bedrock_vectors" {
  bucket = "aws-bucket-ai-agent-vectors-********-v2" #<----- Nombre

  tags = {
    Name        = "Bedrock Vectors Storage"
    Environment = "Dev"
    Project     = "Workshop-AZ-Bedrock-Nova"
    Layer       = "Data-Vectors"
  }
}

# Control de Acceso: Bloquear el acceso público al bucket de vectores (Práctica Recomendada)
resource "aws_s3_bucket_public_access_block" "bedrock_vectors_privacy" {
  bucket = aws_s3_bucket.bedrock_vectors.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Cifrado en reposo (SSE-S3) para proteger la información de los documentos vectorizados
resource "aws_s3_bucket_server_side_encryption_configuration" "bedrock_vectors_crypto" {
  bucket = aws_s3_bucket.bedrock_vectors.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}