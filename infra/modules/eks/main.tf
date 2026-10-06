module "eks" {
  source = "terraform-aws-modules/eks/aws"

  name = module.label.id
  tags = module.label.tags

  kubernetes_version                       = var.k8s_cluster_version
  vpc_id                                   = var.vpc_id
  subnet_ids                               = var.private_subnet_ids
  endpoint_public_access                   = true
  endpoint_private_access                  = true
  enable_cluster_creator_admin_permissions = true
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    aws-ebs-csi-driver = { most_recent = true }
  }


  access_entries = {
    admin = {
      principal_arn = "arn:aws:iam::533267191229:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AdministratorAccess_041ed0ad69adcb5a"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    homelab = {
      min_size     = 1
      max_size     = 8
      desired_size = 6

      instance_types = ["t3.small", "t3.medium"]
      capacity_type  = "SPOT"

      iam_role_additional_policies = {
        ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required" # Enforces IMDSv2
        http_put_response_hop_limit = 2          # Allows pods to access IMDS
      }
    }
  }

  node_security_group_tags = {
    "karpenter.sh/discovery" = module.label.id
  }
}
