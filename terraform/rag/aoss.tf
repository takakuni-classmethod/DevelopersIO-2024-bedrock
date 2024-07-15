########################################################
# Network Policy
########################################################
resource "aws_opensearchserverless_security_policy" "this_network" {
  name        = "${local.prefix}-network-policy"
  type        = "network"
  description = "${local.prefix}-network-policy"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "dashboard",
          Resource = [
            "collection/${local.prefix}-collection"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.prefix}-collection"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ])
}

########################################################
# Encryption Policy
########################################################
resource "aws_opensearchserverless_security_policy" "this_encryption" {
  name        = "${local.prefix}-encryption-policy"
  type        = "encryption"
  description = "${local.prefix}-encryption-policy"
  policy = jsonencode({
    Rules = [
      {
        ResourceType = "collection",
        Resource = [
          "collection/${local.prefix}-collection"
        ]
      }
    ],
    AWSOwnedKey = true
  })
}

########################################################
# Data Access Policy
########################################################
resource "aws_opensearchserverless_access_policy" "this_data" {
  name        = "${local.prefix}-data-policy"
  type        = "data"
  description = "${local.prefix}-data-policy"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/${local.prefix}-collection"
          ],
          Permission = [
            "aoss:DescribeCollectionItems",
            "aoss:CreateCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DeleteCollectionItems"
          ]
        },
        {
          ResourceType = "index",
          Resource = [
            "index/${local.prefix}-collection/*"
          ],
          Permission = [
            "aoss:ReadDocument",
            "aoss:WriteDocument",
            "aoss:DescribeIndex",
            "aoss:CreateIndex",
            "aoss:UpdateIndex",
            "aoss:DeleteIndex"
          ],
        },
      ],
      Principal = [
        aws_iam_role.knowledge_bases.arn,
        "arn:aws:iam::${local.account_id}:role/cm-takakuni.shinnosuke",
        "arn:aws:iam::${local.account_id}:role/devio-2024-sagemaker-domain"
      ]
    }
  ])
}

########################################################
# Collection
########################################################
resource "aws_opensearchserverless_collection" "this" {
  name             = "${local.prefix}-collection"
  description      = "${local.prefix}-collection"
  type             = "VECTORSEARCH"
  standby_replicas = "DISABLED"

  depends_on = [
    aws_opensearchserverless_security_policy.this_network,
    aws_opensearchserverless_security_policy.this_encryption,
    aws_opensearchserverless_access_policy.this_data
  ]
}

########################################################
# Index
########################################################
resource "opensearch_index" "this" {
  name          = "${local.prefix}-vector-index"
  index_knn     = true
  force_destroy = true
  mappings = jsonencode({
    properties = {
      "AMAZON_BEDROCK_METADATA" = {
        type  = "text",
        index = false
      },
      "AMAZON_BEDROCK_TEXT_CHUNK" = {
        type = "text"
      },
      "${local.prefix}-vector" = {
        type      = "knn_vector",
        dimension = var.knowledge_bases.embeddings_model_dimensions,
        method = {
          engine     = "faiss",
          space_type = "l2",
          name       = "hnsw"
          parameters = {}
        }
      },
      "for_managers" = {
        type = "boolean"
      },
      "id" = {
        fields = {
          keyword = {
            ignore_above = 256
            type         = "keyword"
          }
        }
        type = "text"
      },
      "target" = {
        fields = {
          keyword = {
            ignore_above = 256
            type         = "keyword"
          }
        }
        type = "text"
      },
      "x-amz-bedrock-kb-data-source-id" = {
        fields = {
          keyword = {
            ignore_above = 256
            type         = "keyword"
          }
        }
        type = "text"
      },
      "x-amz-bedrock-kb-source-uri" = {
        fields = {
          keyword = {
            ignore_above = 256
            type         = "keyword"
          }
        }
        type = "text"
      }
      year = {
        type = "long"
      }
    }
  })

  depends_on = [
    aws_opensearchserverless_security_policy.this_network,
    aws_opensearchserverless_security_policy.this_encryption,
    aws_opensearchserverless_access_policy.this_data
  ]
}
