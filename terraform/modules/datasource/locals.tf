########################################################
# Region and Account ID
########################################################
data "aws_region" "this" {}
data "aws_caller_identity" "this" {}

locals {
  region     = data.aws_region.this.name
  account_id = data.aws_caller_identity.this.account_id
}
