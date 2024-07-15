terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.57.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-west-2"
}

data "aws_region" "this" {}
data "aws_caller_identity" "this" {}

locals {
  region     = data.aws_region.this.name
  account_id = data.aws_caller_identity.this.account_id
  prefix     = "devio-2024"
}
