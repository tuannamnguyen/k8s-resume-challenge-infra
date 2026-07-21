variable "root_domain_name" {
  type = string
}

variable "acm_domain_validation_options" {
  type        = set(any)
  description = "ACM domains to prove controls of domain"
}

variable "create_route53_record_for_alb" {
  type        = bool
  description = "Whether to create a Route53 record for the ALB"
  default     = false
}

variable "alb_dns_name" {
  type        = string
  description = "The DNS name of the ALB to create a Route53 record for"
}

variable "alb_zone_id" {
  type        = string
  description = "The zone ID of the ALB to create a Route53 record for"
}
