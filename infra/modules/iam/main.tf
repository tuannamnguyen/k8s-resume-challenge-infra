# https://www.gateway-api-controller.eks.aws.dev/v1.0.7/guides/deploy/#setup

resource "aws_iam_policy" "gateway_api_controller_policy" {
  name        = "gateway-api-controller-policy"
  description = "Policy to provide AWS Gateway API permission"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "vpc-lattice:*",
            "ec2:DescribeVpcs",
            "ec2:DescribeSubnets",
            "ec2:DescribeTags",
            "ec2:DescribeSecurityGroups",
            "logs:CreateLogDelivery",
            "logs:GetLogDelivery",
            "logs:DescribeLogGroups",
            "logs:PutResourcePolicy",
            "logs:DescribeResourcePolicies",
            "logs:UpdateLogDelivery",
            "logs:DeleteLogDelivery",
            "logs:ListLogDeliveries",
            "tag:GetResources",
            "firehose:TagDeliveryStream",
            "s3:GetBucketPolicy",
            "s3:PutBucketPolicy",
            "tag:TagResources",
            "tag:UntagResources",
            "acm:ListCertificates"
          ],
          Resource : "*"
        },
        {
          Effect   = "Allow",
          Action   = "iam:CreateServiceLinkedRole",
          Resource = "arn:aws:iam::*:role/aws-service-role/vpc-lattice.amazonaws.com/AWSServiceRoleForVpcLattice",
          Condition = {
            StringLike = {
              "iam:AWSServiceName" = "vpc-lattice.amazonaws.com"
            }
          }
        },
        {
          Effect   = "Allow",
          Action   = "iam:CreateServiceLinkedRole",
          Resource = "arn:aws:iam::*:role/aws-service-role/delivery.logs.amazonaws.com/AWSServiceRoleForLogDelivery",
          Condition = {
            StringLike = {
              "iam:AWSServiceName" = "delivery.logs.amazonaws.com"
            }
          }
        },
      ]

    }
  )
}


resource "aws_iam_role" "vpc_lattice_controller_iam_role" {
  name        = "VPCLatticeControllerIAMRole"
  description = "IAM Role for AWS Gateway API Controller for VPC Lattice"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AllowEksAuthToAssumeRoleForPodIdentity"
          Effect = "Allow"
          Principal = {
            Service = "pods.eks.amazonaws.com"
          }
          Action = [
            "sts:AssumeRole",
            "sts:TagSession"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "gateway_api_controller_policy_attachment" {
  role       = aws_iam_role.vpc_lattice_controller_iam_role.name
  policy_arn = aws_iam_policy.gateway_api_controller_policy.arn
}