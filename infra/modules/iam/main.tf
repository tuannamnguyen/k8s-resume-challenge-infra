module "aws_lb_controller_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "aws-lbc"

  attach_aws_lb_controller_policy = true

  associations = {
    this = {
      cluster_name    = module.eks_label.id
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
    }
  }

  tags = module.label.tags
}

module "aws_ebs_csi_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "aws-ebs-csi"

  attach_aws_ebs_csi_policy = true

  associations = {
    this = {
      cluster_name    = module.eks_label.id
      namespace       = "kube-system"
      service_account = "ebs-csi-controller-sa"
    }
  }

  tags = module.label.tags
}

module "karpenter_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  name   = "karpenter"

  attach_custom_policy = false
  additional_policy_arns = {
    for policy_name, policy in aws_iam_policy.karpenter_controller_policy : policy_name => policy.arn
  }

  associations = {
    this = {
      cluster_name    = module.eks_label.id
      namespace       = "kube-system"
      service_account = "karpenter"
    }
  }

  tags = module.label.tags
}
