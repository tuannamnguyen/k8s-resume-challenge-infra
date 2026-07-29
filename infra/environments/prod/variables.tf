variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "Local AWS CLI profile used by Terraform."
  type        = string
  default     = "admin-access"
}

variable "project_name" {
  type    = string
  default = "k8s-resume-challenge"
}

variable "porkbun_api_key" {
  type = string
}

variable "porkbun_secret_key" {
  type = string
}

variable "alb_dns_name" {
  type = string
}

variable "alb_zone_id" {
  type = string
}

variable "create_route53_record_for_alb" {
  type        = bool
  description = "Whether to create a Route53 record for the ALB"
}

variable "env_keys" {
  type = string
}

variable "env_prod" {
  type = string
}
