########################################################
# IAM Role for Knowledge Bases
########################################################
data "aws_iam_policy_document" "assume_bedrock" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "knowledge_bases" {
  name               = "${local.prefix}-kb-role"
  assume_role_policy = data.aws_iam_policy_document.assume_bedrock.json
  tags = {
    Name = "${local.prefix}-knowledgebase"
  }
}

data "aws_iam_policy_document" "knowledge_bases_llm" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "bedrock:ListFoundationModels",
      "bedrock:ListCustomModels"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "knowledge_bases_llm" {
  name   = "${local.prefix}-kb-llm-policy"
  policy = data.aws_iam_policy_document.knowledge_bases_llm.json
}

resource "aws_iam_role_policy_attachment" "knowledge_bases_llm" {
  role       = aws_iam_role.knowledge_bases.name
  policy_arn = aws_iam_policy.knowledge_bases_llm.arn
}

data "aws_iam_policy_document" "knowledge_bases_datasource" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      module.datasource.bucket.arn,
      "${module.datasource.bucket.arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [local.account_id]
    }
  }
}

resource "aws_iam_policy" "knowledge_bases_datasource" {
  name   = "${local.prefix}-kb-datasource-policy"
  policy = data.aws_iam_policy_document.knowledge_bases_datasource.json
}

resource "aws_iam_role_policy_attachment" "knowledge_bases_datasource" {
  role       = aws_iam_role.knowledge_bases.name
  policy_arn = aws_iam_policy.knowledge_bases_datasource.arn
}

data "aws_iam_policy_document" "knowledge_bases_vectordb" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "aoss:APIAccessAll"
    ]
    resources = [
      aws_opensearchserverless_collection.this.arn
    ]
  }
}

resource "aws_iam_policy" "knowledge_bases_vectordb" {
  name   = "${local.prefix}-kb-vectordb-policy"
  policy = data.aws_iam_policy_document.knowledge_bases_vectordb.json
}

resource "aws_iam_role_policy_attachment" "knowledge_bases_vectordb" {
  role       = aws_iam_role.knowledge_bases.name
  policy_arn = aws_iam_policy.knowledge_bases_vectordb.arn
}

########################################################
# Knowledge 
########################################################
data "aws_bedrock_foundation_model" "embedding" {
  model_id = var.knowledge_bases.embeddings_model_id
}

resource "aws_bedrockagent_knowledge_base" "this" {
  name     = "${local.prefix}-kb"
  role_arn = aws_iam_role.knowledge_bases.arn

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = data.aws_bedrock_foundation_model.embedding.model_arn
    }
  }



  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.this.arn
      vector_index_name = opensearch_index.this.name
      field_mapping {
        metadata_field = "AMAZON_BEDROCK_METADATA"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        vector_field   = "${local.prefix}-vector"
      }
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.knowledge_bases_llm,
    aws_iam_role_policy_attachment.knowledge_bases_datasource,
    aws_iam_role_policy_attachment.knowledge_bases_vectordb,
    aws_opensearchserverless_access_policy.this_data
  ]
}

########################################################
# Knowledge Base Data Source
########################################################
resource "aws_bedrockagent_data_source" "this" {
  name              = "${local.prefix}-datasource"
  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = module.datasource.bucket.arn
    }
  }
}

########################################################
# Knowledge Base Log Group
########################################################
resource "aws_cloudwatch_log_group" "this_bedrock" {
  name = "/aws/bedrock/${local.prefix}-invoke"
}
resource "aws_cloudwatch_log_group" "this_knowledgebase" {
  name = "/aws/bedrock/${aws_bedrockagent_knowledge_base.this.name}"
}
