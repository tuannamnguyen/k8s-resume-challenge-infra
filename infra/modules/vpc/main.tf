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
  tags = merge(module.label.tags, { Name = "${module.label.id}-ec2-endpoint" })


  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.ec2"
  security_group_ids = [aws_security_group.endpoint_sg.id]
  vpc_endpoint_type  = "Interface"

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr" {
  tags = merge(module.label.tags, { Name = "${module.label.id}-ecr-endpoint" })

  for_each = {
    ecr_api_endpoint = "com.amazonaws.${var.region}.ecr.api",
    ecr_dkr_endpoint = "com.amazonaws.${var.region}.ecr.dkr"
  }


  vpc_id             = module.vpc.vpc_id
  service_name       = each.value
  security_group_ids = [aws_security_group.endpoint_sg.id]
  vpc_endpoint_type  = "Interface"

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm" {
  tags = merge(module.label.tags, { Name = "${module.label.id}-ssm-endpoint" })


  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.region}.ssm"
  security_group_ids = [aws_security_group.endpoint_sg.id]
  vpc_endpoint_type  = "Interface"

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  tags = merge(module.label.tags, { Name = "${module.label.id}-s3-endpoint" })

  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
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

resource "aws_vpc_endpoint_subnet_association" "sn_ec2" {
  # Subnet IDs are unknown until the VPC module is applied.  Use their
  # statically known tuple indexes as instance keys instead of the IDs.
  for_each = {
    for index, subnet_id in module.vpc.private_subnets :
    "private-${index}" => subnet_id
  }

  vpc_endpoint_id = aws_vpc_endpoint.ec2.id
  subnet_id       = each.value
}

resource "aws_vpc_endpoint_subnet_association" "sn_ecr" {
  # Associate every ECR interface endpoint with every private subnet. The ECR
  # endpoint resource uses for_each, so each association must address one
  # endpoint instance explicitly.
  for_each = {
    for pair in setproduct(keys(aws_vpc_endpoint.ecr), range(length(module.vpc.private_subnets))) :
    "${pair[0]}-private-${pair[1]}" => {
      vpc_endpoint_id = aws_vpc_endpoint.ecr[pair[0]].id
      subnet_id       = module.vpc.private_subnets[pair[1]]
    }
  }

  vpc_endpoint_id = each.value.vpc_endpoint_id
  subnet_id       = each.value.subnet_id
}

resource "aws_vpc_endpoint_subnet_association" "sn_ssm" {
  # Subnet IDs are unknown until the VPC module is applied.  Use their
  # statically known tuple indexes as instance keys instead of the IDs.
  for_each = {
    for index, subnet_id in module.vpc.private_subnets :
    "private-${index}" => subnet_id
  }

  vpc_endpoint_id = aws_vpc_endpoint.ssm.id
  subnet_id       = each.value
}

resource "aws_vpc_endpoint_route_table_association" "rt_s3" {
  for_each = {
    for index, route_table_id in module.vpc.private_route_table_ids :
    "route-table-${index}" => route_table_id
  }

  route_table_id  = each.value
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
