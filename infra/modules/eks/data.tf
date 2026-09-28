data "aws_iam_session_context" "current" {
  arn = var.caller_arn
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}
