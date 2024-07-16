module "datasource" {
  source = "../modules/datasource"
  prefix = local.prefix
  datasource = {
    force_destroy = true
  }
}

resource "aws_s3_object" "engineer_setup" {
  bucket = module.datasource.bucket.id
  source = "../../document/engineer/01_setup.md"
  key    = "engineer/01_setup.md"
}
resource "aws_s3_object" "engineer_setup_metadata" {
  bucket = module.datasource.bucket.id
  source = "../../document/engineer/01_setup.md.metadata.json"
  key    = "engineer/01_setup.md.metadata.json"
}

resource "aws_s3_object" "sales_setup" {
  bucket = module.datasource.bucket.id
  source = "../../document/sales/01_setup.md"
  key    = "sales/01_setup.md"
}
resource "aws_s3_object" "sales_setup_metadata" {
  bucket = module.datasource.bucket.id
  source = "../../document/sales/01_setup.md.metadata.json"
  key    = "sales/01_setup.md.metadata.json"
}

resource "aws_s3_object" "all_moved" {
  bucket = module.datasource.bucket.id
  source = "../../document/all/moved.md"
  key    = "all/moved.md"
}
resource "aws_s3_object" "all_moved_metadata" {
  bucket = module.datasource.bucket.id
  source = "../../document/all/moved.md.metadata.json"
  key    = "all/moved.md.metadata.json"
}
resource "aws_s3_object" "all_change_account" {
  bucket = module.datasource.bucket.id
  source = "../../document/all/change-account.md"
  key    = "all/change-account.md"
}
resource "aws_s3_object" "all_change_account_metadata" {
  bucket = module.datasource.bucket.id
  source = "../../document/all/change-account.md.metadata.json"
  key    = "all/change-account.md.metadata.json"
}
resource "aws_s3_object" "all_expense" {
  bucket = module.datasource.bucket.id
  source = "../../document/all/expense.md"
  key    = "all/expense.md"
}
resource "aws_s3_object" "all_expense_metadata" {
  bucket = module.datasource.bucket.id
  source = "../../document/all/expense.md.metadata.json"
  key    = "all/expense.md.metadata.json"
}
