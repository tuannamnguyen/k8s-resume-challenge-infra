variable "account_id" {
  type = string
}
variable "DB_USER" {
  type    = string
  default = ""
}

variable "DB_PASS" {
  type    = string
  default = ""
}

variable "context" {
  description = "Single object for setting entire context at once"
  type        = any
}
