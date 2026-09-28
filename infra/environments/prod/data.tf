data "aws_iam_session_context" "current" {
  arn = module.aws_context.caller_arn
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}
