module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = module.label.id
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = module.eks_label.id
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = module.label.tags
}

resource "aws_vpc_endpoint" "ec2" {
  tags = merge(module.label.tags, { Name = "${module.label.id}-ec2-endpoint" })


  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ec2"
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr" {
  tags = merge(module.label.tags, { Name = "${module.label.id}-ecr-endpoint" })

  for_each = {
    ecr_api_endpoint = "com.amazonaws.${var.region}.ecr.api",
    ecr_dkr_endpoint = "com.amazonaws.${var.region}.ecr.dkr"
  }


  vpc_id              = module.vpc.vpc_id
  service_name        = each.value
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm" {
  tags = merge(module.label.tags, { Name = "${module.label.id}-ssm-endpoint" })


  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.ssm"
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  tags = merge(module.label.tags, { Name = "${module.label.id}-s3-endpoint" })

  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids   = module.vpc.private_route_table_ids
  vpc_endpoint_type = "Gateway"
}

resource "aws_security_group" "endpoint_sg" {
  tags = merge(module.label.tags, { Name = "${module.label.id}-endpoint-sg" })


  name_prefix = module.label.id
  description = "SG for VPC endpoints"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  tags = module.label.tags

  security_group_id = aws_security_group.endpoint_sg.id
  cidr_ipv4         = module.vpc.vpc_cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
