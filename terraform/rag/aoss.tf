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
  analysis_tokenizer = jsonencode({
    custom_kuromoji_tokenizer = {
      type = "kuromoji_tokenizer"
      mode = "search"
    }
  })
  analysis_filter = jsonencode({
    custom_kuromoji_readingform = {
      type       = "kuromoji_readingform"
      use_romaji = true
    }
  })
  analysis_analyzer = jsonencode({
    custom_kuromoji_analyzer = {
      type = "custom"
      char_filter = [
        "icu_normalizer",
        "kuromoji_iteration_mark"
      ]
      tokenizer = "custom_kuromoji_tokenizer"
      filter = [                       # Token Filter
        "kuromoji_baseform",           # 基本形への変換 「美しかった」→「美しい」
        "kuromoji_part_of_speech",     # 品詞除去 「寿司がおいしいね」→ [寿司, おいしい]
        "ja_stop",                     # ストップワードの除去 これ、それ、あれ
        "kuromoji_stemmer",            # 長音除去 サーバー → サーバ
        "custom_kuromoji_readingform", # 読み仮名付与
        "kuromoji_number"              # 漢数字の半角数字化
      ],
    }
  })
  mappings = jsonencode({
    properties = {
      AMAZON_BEDROCK_METADATA = {
        type  = "text",
        index = false
      },
      AMAZON_BEDROCK_TEXT_CHUNK = {
        type     = "text",
        analyzer = "custom_kuromoji_analyzer"
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
      for_managers = {
        type = "boolean"
      },
      id = {
        fields = {
          keyword = {
            ignore_above = 256
            type         = "keyword"
          }
        }
        type = "text"
      },
      target = {
        fields = {
          keyword = {
            ignore_above = 256
            type         = "keyword"
          }
        }
        type = "text"
      },
      x-amz-bedrock-kb-data-source-id = {
        fields = {
          keyword = {
            ignore_above = 256
            type         = "keyword"
          }
        }
        type = "text"
      },
      x-amz-bedrock-kb-source-uri = {
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
