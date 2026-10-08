variable "secret_arn" {
  type    = string
  default = ""
}

variable "context" {
  description = "Single object for setting entire context at once"
  type        = any
}
