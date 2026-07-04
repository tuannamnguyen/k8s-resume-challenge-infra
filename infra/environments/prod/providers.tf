provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "porkbun" {
  api_key        = var.porkbun_api_key
  secret_api_key = var.porkbun_secret_key
}
