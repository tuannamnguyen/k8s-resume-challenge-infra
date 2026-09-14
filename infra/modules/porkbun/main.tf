resource "porkbun_domain_nameservers" "nameservers" {
  domain      = var.root_domain_name
  nameservers = var.nameservers
}
