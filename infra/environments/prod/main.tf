module "aws_context" {
  source = "../../modules/aws_context"
}

module "vpc" {
  source = "../../modules/vpc"

  environment  = "prod"
  project_name = var.project_name
}


module "eks" {
  source = "../../modules/eks"

  environment        = "prod"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}


module "route_53" {
  source                        = "../../modules/route_53"
  acm_domain_validation_options = module.acm.domain_validation_option
  root_domain_name              = "tunebridge.online"
}

module "acm" {
  source                  = "../../modules/acm"
  validation_record_fqdns = module.route_53.validation_record_fqdns
  root_domain_name        = "tunebridge.online"

}

module "iam" {
  source = "../../modules/iam"
}
module "porkbun" {
  source           = "../../modules/porkbun"
  root_domain_name = "tunebridge.online"
  nameservers      = module.route_53.nameservers
}
