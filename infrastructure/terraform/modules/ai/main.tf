locals {
  embedding_model_arn = "arn:${var.partition}:bedrock:${var.region}::foundation-model/${var.embedding_model_id}"

  vector_bucket_arn = "arn:${var.partition}:s3vectors:${var.region}:${data.aws_caller_identity.current.account_id}:bucket/${var.vector_bucket_name}"

  vector_index_arn = "arn:${var.partition}:s3vectors:${var.region}:${data.aws_caller_identity.current.account_id}:bucket/${var.vector_bucket_name}/index/${var.vector_index_name}"
}

resource "aws_s3_bucket" "documents" {
  bucket = var.documents_bucket_name
  tags   = var.common_tags
}

resource "aws_s3_object" "knowledge_documents" {
  for_each = fileset("${path.root}/../../knowledge-base", "*.pdf")

  bucket = aws_s3_bucket.documents.id
  key    = each.value

  source = "${path.root}/../../knowledge-base/${each.value}"
  etag   = filemd5("${path.root}/../../knowledge-base/${each.value}")
}

resource "aws_s3_bucket_public_access_block" "documents" {
  bucket = aws_s3_bucket.documents.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "documents" {
  bucket = aws_s3_bucket.documents.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3vectors_vector_bucket" "kb" {
  count              = var.enable_knowledge_base ? 1 : 0
  vector_bucket_name = var.vector_bucket_name
  tags               = var.common_tags
}

resource "aws_s3vectors_index" "kb" {
  count              = var.enable_knowledge_base ? 1 : 0
  vector_bucket_name = aws_s3vectors_vector_bucket.kb[0].vector_bucket_name
  index_name         = var.vector_index_name
  data_type          = "float32"
  dimension          = var.embedding_dimensions
  distance_metric    = "cosine"

  metadata_configuration {
    non_filterable_metadata_keys = [
      "AMAZON_BEDROCK_TEXT",
      "AMAZON_BEDROCK_METADATA"
    ]
  }

  tags = var.common_tags
}

resource "aws_iam_role" "bedrock_kb" {
  count = var.enable_knowledge_base ? 1 : 0
  name  = "${var.app_name}-bedrock-kb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "bedrock.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy" "bedrock_kb" {
  count = var.enable_knowledge_base ? 1 : 0
  name  = "${var.app_name}-bedrock-kb-policy"
  role  = aws_iam_role.bedrock_kb[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadSourceDocuments"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          aws_s3_bucket.documents.arn,
          "${aws_s3_bucket.documents.arn}/*"
        ]
      },
      {
        Sid    = "UseEmbeddingModel"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = local.embedding_model_arn
      },
      {
        Sid    = "UseS3Vectors"
        Effect = "Allow"
        Action = [
          "s3vectors:GetVectorBucket",
          "s3vectors:GetIndex",
          "s3vectors:ListIndexes",
          "s3vectors:PutVectors",
          "s3vectors:GetVectors",
          "s3vectors:QueryVectors",
          "s3vectors:DeleteVectors"
        ]
        Resource = [
          local.vector_bucket_arn,
          local.vector_index_arn
        ]
      }
    ]
  })
}

resource "aws_bedrockagent_knowledge_base" "kb" {
  count    = var.enable_knowledge_base ? 1 : 0
  name     = "${var.app_name}-knowledge-base"
  role_arn = aws_iam_role.bedrock_kb[0].arn

  knowledge_base_configuration {
    type = "VECTOR"

    vector_knowledge_base_configuration {
      embedding_model_arn = local.embedding_model_arn

      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions          = var.embedding_dimensions
          embedding_data_type = "FLOAT32"
        }
      }
    }
  }

  storage_configuration {
    type = "S3_VECTORS"

    s3_vectors_configuration {
      index_arn = aws_s3vectors_index.kb[0].index_arn
    }
  }

  depends_on = [
    aws_s3vectors_index.kb,
    aws_iam_role_policy.bedrock_kb
  ]

  tags = var.common_tags
}

resource "aws_bedrockagent_data_source" "documents" {
  count             = var.enable_knowledge_base ? 1 : 0
  knowledge_base_id = aws_bedrockagent_knowledge_base.kb[0].id
  name              = "${var.app_name}-s3-documents"

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn = aws_s3_bucket.documents.arn
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"

      fixed_size_chunking_configuration {
        max_tokens         = 500
        overlap_percentage = 20
      }
    }
  }
}
