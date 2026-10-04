output "karpenter_node_role_name" {
  description = "Karpenter IAM node role name"
  value       = aws_iam_role.karpenter_node_role.name
}
