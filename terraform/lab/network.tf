module "network" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "5.9.0"
  enable_nat_gateway = false
  azs                = ["${local.region}a", "${local.region}c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
}

module "sg_sagemaker" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name         = "${local.prefix}-sagemaker-sg"
  vpc_id       = module.network.vpc_id
  egress_rules = ["all-all"]
}
