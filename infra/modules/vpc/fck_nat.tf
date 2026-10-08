module "fck-nat" {
  source  = "RaJiska/fck-nat/aws"
  version = "1.6.1"

  name      = "my-fck-nat"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnets[0]

  attach_ssm_policy = true

  update_route_tables = true
  route_tables_ids = {
    for i, rt in module.vpc.private_route_table_ids :
    "route-table-${i}" => rt
  }

  tags = module.label.tags
}
