output "aws_account_id" {
  description = "AWS account ID used by this environment."
  value       = module.aws_context.account_id
}

output "aws_region" {
  description = "AWS region used by this environment."
  value       = module.aws_context.region
}

output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "vpc_id" {
  description = "VPC ID used by this environment."
  value       = module.vpc.vpc_id
}


output "acm_cert_arn" {
  value       = module.acm.acm_cert_arn
  description = "ACM certificate ARN"
}
