variable "root_domain_name" {
  type = string
}

variable "acm_domain_validation_options" {
  type        = set(any)
  description = "ACM domains to prove controls of domain"
}
