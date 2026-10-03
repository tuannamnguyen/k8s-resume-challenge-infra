variable "cluster_name" {
  type = string
}

variable "secret_arn" {
  type    = string
  default = ""
}

variable "context" {
  description = "Single object for setting entire context at once"
  type        = any
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "account_id" {
  description = "AWS account ID"
  type        = string
}
