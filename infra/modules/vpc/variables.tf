variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "context" {
  description = "Single object for setting entire context at once"
  type        = any
}

variable "region" {
  description = "Current AWS region name."
  type        = string
}
