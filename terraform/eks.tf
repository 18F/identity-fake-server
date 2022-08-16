module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.26.6"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

    attach_cluster_primary_security_group = true

    # Disabling and using externally provided security groups
    create_security_group = false

    # We are using the IRSA created below for permissions
    # However, we have to provision a new cluster with the policy attached FIRST
    # before we can disable. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the new cluster
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["c6i.xlarge"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      vpc_security_group_ids = [
        aws_security_group.node_group_one.id
      ]
    }

    two = {
      name = "node-group-2"

      instance_types = ["c6i.xlarge"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      vpc_security_group_ids = [
        aws_security_group.node_group_two.id
      ]
    }
  }
}
