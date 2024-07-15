terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.57.0"
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "2.3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

provider "opensearch" {
  url         = aws_opensearchserverless_collection.this.collection_endpoint
  aws_region  = "us-west-2"
  healthcheck = false
}

data "aws_region" "this" {}
data "aws_caller_identity" "this" {}

locals {
  region     = data.aws_region.this.name
  account_id = data.aws_caller_identity.this.account_id
  prefix     = "devio-2024"
}
