variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "ID of the VPC where EKS will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of IDs of private subnets"
  type        = list(string)
}

variable "k8s_cluster_version" {
  description = "K8s version for the EKS cluster"
  type        = string
  default     = "1.35"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast"
}

variable "context" {
  description = "Single object for setting entire context at once"
  type        = any
}
variable "create_argocd" {
  description = "Controls if ArgoCD should be created"
  type        = bool
  default     = false
}
