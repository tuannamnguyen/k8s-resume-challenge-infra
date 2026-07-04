module "eks" {
  source = "terraform-aws-modules/eks/aws"

  name               = "${var.project_name}-${var.environment}"
  kubernetes_version = var.k8s_cluster_version

  # find a way to include AmazonEKSWorkerNodePolicy and AmazonEC2ContainerRegistryPullOnly
  # https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html
  compute_config = {
    enabled = false
  }

  endpoint_public_access  = true
  endpoint_private_access = false

  enable_cluster_creator_admin_permissions = true

  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids


  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}
