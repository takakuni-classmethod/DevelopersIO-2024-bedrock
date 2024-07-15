########################################################
# Data Source for Knowledge Base
########################################################
resource "aws_s3_bucket" "this" {
  bucket        = "${var.prefix}-kb-datasource-${local.account_id}-${local.region}"
  force_destroy = var.datasource.force_destroy
  tags = {
    Name = "${var.prefix}-kb-datasource-${local.account_id}-${local.region}"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
