terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.52.0, < 7.0.0"
    }

    porkbun = {
      source  = "jianyuan/porkbun"
      version = "0.3.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
  }

  cloud {

    organization = "nam_test_org"

    workspaces {
      name = "homelab-workspace"
    }
  }
}
