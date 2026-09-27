output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
  type        = string
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "auth_token" {
  description = "Authentication token to communicate with an EKS cluster"
  value       = data.aws_eks_cluster_auth.cluster_auth.token
}
