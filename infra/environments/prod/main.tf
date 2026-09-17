module "aws_context" {
  source = "../../modules/aws_context"
}

module "vpc" {
  source = "../../modules/vpc"

  environment  = "prod"
  project_name = var.project_name
  context      = module.label.context
  region       = module.aws_context.region
}


module "eks" {
  source = "../../modules/eks"

  environment        = "prod"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  context            = module.label.context
  create_argocd      = true
  caller_arn         = module.aws_context.caller_arn
}


module "route_53" {
  source                        = "../../modules/route_53"
  acm_domain_validation_options = module.acm.domain_validation_option
  root_domain_name              = "tunebridge.online"
  alb_zone_id                   = var.alb_zone_id
  alb_dns_name                  = var.alb_dns_name
  create_route53_record_for_alb = var.create_route53_record_for_alb
}

module "acm" {
  source                  = "../../modules/acm"
  validation_record_fqdns = module.route_53.validation_record_fqdns
  root_domain_name        = "tunebridge.online"

}

module "iam" {
  source       = "../../modules/iam"
  cluster_name = module.eks.cluster_name
  context      = module.label.context
}

# module "secrets_manager" {
#   source       = "../../modules/secret_manager"
#   project_name = var.project_name
#   account_id   = module.aws_context.account_id
#   env_keys     = var.env_keys
#   env_prod     = var.env_prod
# }

module "porkbun" {
  source           = "../../modules/porkbun"
  root_domain_name = "tunebridge.online"
  nameservers      = module.route_53.nameservers
}


module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # insert the 12 required variables here

  namespace   = "homelab"
  environment = "apse1"
  stage       = "dev"
  tags = {
    Terraform = true
  }
}
