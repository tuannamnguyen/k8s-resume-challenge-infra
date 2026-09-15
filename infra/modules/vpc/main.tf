module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = module.label.id
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = module.label.tags
}

resource "aws_vpc_endpoint" "ec2" {
  tags = module.label.tags


  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.ec2"
  security_group_ids = [aws_security_group.endpoint_sg.id]
  vpc_endpoint_type  = "Interface"

  private_dns_enabled = true
}

resource "aws_security_group" "endpoint_sg" {
  tags = module.label.tags

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

resource "aws_vpc_endpoint_subnet_association" "sn_ec2" {
  vpc_endpoint_id = aws_vpc_endpoint.ec2.id
  subnet_id       = module.vpc.default_vpc_id
}
