output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
  type        = string
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}
