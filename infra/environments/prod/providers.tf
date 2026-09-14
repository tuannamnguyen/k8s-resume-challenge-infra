provider "aws" {
  region = "ap-southeast-1"
  shared_config_files = [var.tfc_aws_dynamic_credentials.default.shared_config_file]
}

provider "porkbun" {
  api_key        = var.porkbun_api_key
  secret_api_key = var.porkbun_secret_key
}
