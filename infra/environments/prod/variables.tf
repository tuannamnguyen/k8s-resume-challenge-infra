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
