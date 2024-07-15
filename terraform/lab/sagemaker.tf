data "aws_iam_policy_document" "assume_sagemaker" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sagemaker_domain" {
  name               = "${local.prefix}-sagemaker-domain"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_sagemaker.json
}

resource "aws_iam_role_policy_attachment" "sagemaker_domain_sagemakerfullaccess" {
  role       = aws_iam_role.sagemaker_domain.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}
resource "aws_iam_role_policy_attachment" "sagemaker_domain_bedrockfullaccess" {
  role       = aws_iam_role.sagemaker_domain.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

resource "aws_sagemaker_domain" "this" {
  domain_name             = local.prefix
  auth_mode               = "IAM"
  app_network_access_type = "PublicInternetOnly"
  vpc_id                  = module.network.vpc_id
  subnet_ids              = module.network.private_subnets
  domain_settings {
    security_group_ids = [module.sg_sagemaker.security_group_id]
  }
  default_user_settings {
    execution_role    = aws_iam_role.sagemaker_domain.arn
    studio_web_portal = "ENABLED"
    security_groups   = [module.sg_sagemaker.security_group_id]
  }
  default_space_settings {
    execution_role  = aws_iam_role.sagemaker_domain.arn
    security_groups = [module.sg_sagemaker.security_group_id]
  }
  retention_policy {
    home_efs_file_system = "Delete"
  }
}

resource "aws_sagemaker_user_profile" "this" {
  domain_id         = aws_sagemaker_domain.this.id
  user_profile_name = "${local.prefix}-user"
}

resource "aws_sagemaker_space" "this" {
  domain_id  = aws_sagemaker_domain.this.id
  space_name = "${local.prefix}-space"
  ownership_settings {
    owner_user_profile_name = aws_sagemaker_user_profile.this.user_profile_name
  }
  space_sharing_settings {
    sharing_type = "Private"
  }
  space_settings {
    app_type = "CodeEditor"
    code_editor_app_settings {
      default_resource_spec {
        instance_type                 = "ml.t3.medium"
        sagemaker_image_arn           = "arn:aws:sagemaker:ap-northeast-1:010972774902:image/sagemaker-distribution-cpu"
        sagemaker_image_version_alias = "1.9.0"
      }
    }
  }
}
