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
