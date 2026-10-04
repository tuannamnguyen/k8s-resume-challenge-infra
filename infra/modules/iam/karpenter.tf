locals {
  karpenter_policy_statements = [
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
        { test = "StringEquals", variable = "aws:ResourceTag/kubernetes.io/cluster/${module.eks_label.id}", values = ["owned"] },
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
        { test = "StringEquals", variable = "aws:RequestTag/kubernetes.io/cluster/${module.eks_label.id}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:RequestTag/eks:eks-cluster-name", values = [module.eks_label.id] },
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
        { test = "StringEquals", variable = "aws:RequestTag/kubernetes.io/cluster/${module.eks_label.id}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:RequestTag/eks:eks-cluster-name", values = [module.eks_label.id] },
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
        { test = "StringEquals", variable = "aws:ResourceTag/kubernetes.io/cluster/${module.eks_label.id}", values = ["owned"] },
        { test = "StringLike", variable = "aws:ResourceTag/karpenter.sh/nodepool", values = ["*"] },
        { test = "StringEqualsIfExists", variable = "aws:RequestTag/eks:eks-cluster-name", values = [module.eks_label.id] },
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
        { test = "StringEquals", variable = "aws:ResourceTag/kubernetes.io/cluster/${module.eks_label.id}", values = ["owned"] },
        { test = "StringLike", variable = "aws:ResourceTag/karpenter.sh/nodepool", values = ["*"] },
      ]
    },
    {
      sid       = "AllowPassingInstanceRole"
      effect    = "Allow"
      resources = ["arn:aws:iam::${var.account_id}:role/KarpenterNodeRole-${module.eks_label.id}"]
      actions   = ["iam:PassRole"]
      condition = [{ test = "StringEquals", variable = "iam:PassedToService", values = ["ec2.amazonaws.com", "ec2.amazonaws.com.cn"] }]
    },
    {
      sid       = "AllowScopedInstanceProfileCreationActions"
      effect    = "Allow"
      resources = ["arn:aws:iam::${var.account_id}:instance-profile/*"]
      actions   = ["iam:CreateInstanceProfile"]
      condition = [
        { test = "StringEquals", variable = "aws:RequestTag/kubernetes.io/cluster/${module.eks_label.id}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:RequestTag/eks:eks-cluster-name", values = [module.eks_label.id] },
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
        { test = "StringEquals", variable = "aws:ResourceTag/kubernetes.io/cluster/${module.eks_label.id}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:ResourceTag/topology.kubernetes.io/region", values = [var.aws_region] },
        { test = "StringEquals", variable = "aws:RequestTag/kubernetes.io/cluster/${module.eks_label.id}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:RequestTag/eks:eks-cluster-name", values = [module.eks_label.id] },
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
        { test = "StringEquals", variable = "aws:ResourceTag/kubernetes.io/cluster/${module.eks_label.id}", values = ["owned"] },
        { test = "StringEquals", variable = "aws:ResourceTag/topology.kubernetes.io/region", values = [var.aws_region] },
        { test = "StringLike", variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass", values = ["*"] },
      ]
    },
    {
      sid       = "AllowAPIServerEndpointDiscovery"
      effect    = "Allow"
      resources = ["arn:aws:eks:${var.aws_region}:${var.account_id}:cluster/${module.eks_label.id}"]
      actions   = ["eks:DescribeCluster"]
    },
    {
      sid       = "AllowInterruptionQueueActions"
      effect    = "Allow"
      resources = ["arn:aws:sqs:${var.aws_region}:${var.account_id}:${module.eks_label.id}"]
      actions   = ["sqs:DeleteMessage", "sqs:GetQueueUrl", "sqs:ReceiveMessage"]
    },
    {
      sid       = "AllowZonalShiftStatusReadOnly"
      effect    = "Allow"
      resources = ["*"]
      actions   = ["arc-zonal-shift:GetManagedResource"]
      condition = [{ test = "StringEquals", variable = "arc-zonal-shift:ResourceIdentifier", values = ["arn:aws:eks:${var.aws_region}:${var.account_id}:cluster/${module.eks_label.id}"] }]
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

  karpenter_policy_groups = {
    node_lifecycle = [
      "AllowScopedEC2InstanceAccessActions",
      "AllowScopedEC2LaunchTemplateAccessActions",
      "AllowScopedEC2InstanceActionsWithTags",
      "AllowScopedResourceCreationTagging",
      "AllowScopedResourceTagging",
      "AllowScopedDeletion",
    ]
    iam_integration = [
      "AllowPassingInstanceRole",
      "AllowScopedInstanceProfileCreationActions",
      "AllowScopedInstanceProfileTagActions",
      "AllowScopedInstanceProfileActions",
    ]
    integrations = [
      "AllowAPIServerEndpointDiscovery",
      "AllowInterruptionQueueActions",
      "AllowZonalShiftStatusReadOnly",
    ]
    resource_discovery = [
      "AllowRegionalReadActions",
      "AllowSSMReadActions",
      "AllowPricingReadActions",
      "AllowUnscopedInstanceProfileListAction",
      "AllowInstanceProfileReadActions",
    ]
  }
}

data "aws_iam_policy_document" "karpenter" {
  for_each = local.karpenter_policy_groups

  dynamic "statement" {
    for_each = [
      for item in local.karpenter_policy_statements : item
      if contains(each.value, item.sid)
    ]

    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "condition" {
        for_each = lookup(statement.value, "condition", [])

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_iam_policy" "karpenter_controller_policy" {
  for_each = data.aws_iam_policy_document.karpenter

  name   = "karpenter-${each.key}-${substr(md5(module.eks_label.id), 0, 12)}"
  policy = each.value.json
  tags   = module.label.tags
}

resource "aws_iam_role" "karpenter_node_role" {
  name = "KarpenterNodeRole-${module.eks_label.id}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_node_role_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])

  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = each.value
}
