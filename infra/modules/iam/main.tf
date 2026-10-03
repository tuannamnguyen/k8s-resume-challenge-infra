module "aws_lb_controller_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"

  name = "aws-lbc"

  attach_aws_lb_controller_policy = true

  associations = {
    this = {
      cluster_name    = var.cluster_name
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
      cluster_name    = var.cluster_name
      namespace       = "kube-system"
      service_account = "ebs-csi-controller-sa"
    }
  }

  tags = module.label.tags
}

module "karpenter_pod_identity" {
  source = "terraform-aws-modules/eks-pod-identity/aws"
  name   = "karpenter"

  policy_statements = [
    {
      sid    = "AllowScopedEC2InstanceAccessActions"
      effect = "Allow"
      resources = [
        "arn:aws:ec2:${var.aws_region}::image/*",
        "arn:aws:ec2:${var.aws_region}::snapshot/*",
        "arn:aws:ec2:${var.aws_region}:*:security-group/*",
        "arn:aws:ec2:${var.aws_region}:*:subnet/*",
        "arn:aws:ec2:${var.aws_region}:*:capacity-reservation/*",
        "arn:aws:ec2:${var.aws_region}:*:placement-group/*",
      ]
      actions = ["ec2:RunInstances", "ec2:CreateFleet"]
    },
    {
      sid       = "AllowScopedEC2LaunchTemplateAccessActions"
      effect    = "Allow"
      resources = ["arn:aws:ec2:${var.aws_region}:*:launch-template/*"]
      actions   = ["ec2:RunInstances", "ec2:CreateFleet"]
      condition = [
        { test = "StringEquals", variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}", values = ["owned"] },
        { test = "StringLike", variable = "aws:ResourceTag/karpenter.sh/nodepool", values = ["*"] },
      ]
    },
    {
      sid    = "AllowScopedEC2InstanceActionsWithTags"
      effect = "Allow"
      resources = [
        "arn:aws:ec2:${var.aws_region}:*:fleet/*",
        "arn:aws:ec2:${var.aws_region}:*:instance/*",
        "arn:aws:ec2:${var.aws_region}:*:volume/*",
        "arn:aws:ec2:${var.aws_region}:*:network-interface/*",
        "arn:aws:ec2:${var.aws_region}:*:launch-template/*",
        "arn:aws:ec2:${var.aws_region}:*:spot-instances-request/*",
      ]
      actions = ["ec2:RunInstances", "ec2:CreateFleet", "ec2:CreateLaunchTemplate"]
      condition = [
        { test = "StringEquals", variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:RequestTag/eks:eks-cluster-name", values = [var.cluster_name] },
        { test = "StringLike", variable = "aws:RequestTag/karpenter.sh/nodepool", values = ["*"] },
      ]
    },
    {
      sid    = "AllowScopedResourceCreationTagging"
      effect = "Allow"
      resources = [
        "arn:aws:ec2:${var.aws_region}:*:fleet/*",
        "arn:aws:ec2:${var.aws_region}:*:instance/*",
        "arn:aws:ec2:${var.aws_region}:*:volume/*",
        "arn:aws:ec2:${var.aws_region}:*:network-interface/*",
        "arn:aws:ec2:${var.aws_region}:*:launch-template/*",
        "arn:aws:ec2:${var.aws_region}:*:spot-instances-request/*",
      ]
      actions = ["ec2:CreateTags"]
      condition = [
        { test = "StringEquals", variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:RequestTag/eks:eks-cluster-name", values = [var.cluster_name] },
        { test = "StringEquals", variable = "ec2:CreateAction", values = ["RunInstances", "CreateFleet", "CreateLaunchTemplate"] },
        { test = "StringLike", variable = "aws:RequestTag/karpenter.sh/nodepool", values = ["*"] },
      ]
    },
    {
      sid       = "AllowScopedResourceTagging"
      effect    = "Allow"
      resources = ["arn:aws:ec2:${var.aws_region}:*:instance/*"]
      actions   = ["ec2:CreateTags"]
      condition = [
        { test = "StringEquals", variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}", values = ["owned"] },
        { test = "StringLike", variable = "aws:ResourceTag/karpenter.sh/nodepool", values = ["*"] },
        { test = "StringEqualsIfExists", variable = "aws:RequestTag/eks:eks-cluster-name", values = [var.cluster_name] },
        { test = "ForAllValues:StringEquals", variable = "aws:TagKeys", values = ["eks:eks-cluster-name", "karpenter.sh/nodeclaim", "Name"] },
      ]
    },
    {
      sid    = "AllowScopedDeletion"
      effect = "Allow"
      resources = [
        "arn:aws:ec2:${var.aws_region}:*:instance/*",
        "arn:aws:ec2:${var.aws_region}:*:launch-template/*",
      ]
      actions = ["ec2:TerminateInstances", "ec2:DeleteLaunchTemplate"]
      condition = [
        { test = "StringEquals", variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}", values = ["owned"] },
        { test = "StringLike", variable = "aws:ResourceTag/karpenter.sh/nodepool", values = ["*"] },
      ]
    },
    {
      sid       = "AllowPassingInstanceRole"
      effect    = "Allow"
      resources = ["arn:aws:iam::${var.account_id}:role/KarpenterNodeRole-${var.cluster_name}"]
      actions   = ["iam:PassRole"]
      condition = [{ test = "StringEquals", variable = "iam:PassedToService", values = ["ec2.amazonaws.com", "ec2.amazonaws.com.cn"] }]
    },
    {
      sid       = "AllowScopedInstanceProfileCreationActions"
      effect    = "Allow"
      resources = ["arn:aws:iam::${var.account_id}:instance-profile/*"]
      actions   = ["iam:CreateInstanceProfile"]
      condition = [
        { test = "StringEquals", variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:RequestTag/eks:eks-cluster-name", values = [var.cluster_name] },
        { test = "StringEquals", variable = "aws:RequestTag/topology.kubernetes.io/region", values = [var.aws_region] },
        { test = "StringLike", variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass", values = ["*"] },
      ]
    },
    {
      sid       = "AllowScopedInstanceProfileTagActions"
      effect    = "Allow"
      resources = ["arn:aws:iam::${var.account_id}:instance-profile/*"]
      actions   = ["iam:TagInstanceProfile"]
      condition = [
        { test = "StringEquals", variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:ResourceTag/topology.kubernetes.io/region", values = [var.aws_region] },
        { test = "StringEquals", variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:RequestTag/eks:eks-cluster-name", values = [var.cluster_name] },
        { test = "StringEquals", variable = "aws:RequestTag/topology.kubernetes.io/region", values = [var.aws_region] },
        { test = "StringLike", variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass", values = ["*"] },
        { test = "StringLike", variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass", values = ["*"] },
      ]
    },
    {
      sid       = "AllowScopedInstanceProfileActions"
      effect    = "Allow"
      resources = ["arn:aws:iam::${var.account_id}:instance-profile/*"]
      actions   = ["iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile", "iam:DeleteInstanceProfile"]
      condition = [
        { test = "StringEquals", variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:ResourceTag/topology.kubernetes.io/region", values = [var.aws_region] },
        { test = "StringLike", variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass", values = ["*"] },
      ]
    },
    {
      sid       = "AllowAPIServerEndpointDiscovery"
      effect    = "Allow"
      resources = ["arn:aws:eks:${var.aws_region}:${var.account_id}:cluster/${var.cluster_name}"]
      actions   = ["eks:DescribeCluster"]
    },
    {
      sid       = "AllowInterruptionQueueActions"
      effect    = "Allow"
      resources = ["arn:aws:sqs:${var.aws_region}:${var.account_id}:${var.cluster_name}"]
      actions   = ["sqs:DeleteMessage", "sqs:GetQueueUrl", "sqs:ReceiveMessage"]
    },
    {
      sid       = "AllowZonalShiftStatusReadOnly"
      effect    = "Allow"
      resources = ["*"]
      actions   = ["arc-zonal-shift:GetManagedResource"]
      condition = [{ test = "StringEquals", variable = "arc-zonal-shift:ResourceIdentifier", values = ["arn:aws:eks:${var.aws_region}:${var.account_id}:cluster/${var.cluster_name}"] }]
    },
    {
      sid       = "AllowRegionalReadActions"
      effect    = "Allow"
      resources = ["*"]
      actions = [
        "ec2:DescribeCapacityReservations", "ec2:DescribeImages", "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus", "ec2:DescribeInstanceTypeOfferings", "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplates", "ec2:DescribePlacementGroups", "ec2:DescribeSecurityGroups",
        "ec2:DescribeSpotPriceHistory", "ec2:DescribeSubnets",
      ]
      condition = [{ test = "StringEquals", variable = "aws:RequestedRegion", values = [var.aws_region] }]
    },
    {
      sid       = "AllowSSMReadActions"
      effect    = "Allow"
      resources = ["arn:aws:ssm:${var.aws_region}::parameter/aws/service/*"]
      actions   = ["ssm:GetParameter"]
    },
    {
      sid       = "AllowPricingReadActions"
      effect    = "Allow"
      resources = ["*"]
      actions   = ["pricing:GetProducts"]
    },
    {
      sid       = "AllowUnscopedInstanceProfileListAction"
      effect    = "Allow"
      resources = ["*"]
      actions   = ["iam:ListInstanceProfiles"]
    },
    {
      sid       = "AllowInstanceProfileReadActions"
      effect    = "Allow"
      resources = ["arn:aws:iam::${var.account_id}:instance-profile/*"]
      actions   = ["iam:GetInstanceProfile"]
    },
  ]

  associations = {
    this = {
      cluster_name    = var.cluster_name
      namespace       = "kube-system"
      service_account = "karpenter"
    }
  }

  tags = module.label.tags
}
