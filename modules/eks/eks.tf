data "aws_partition" "current" {}
locals {
  cluster_name = "${var.eks_cluster_base_name}-${random_string.suffix.result}"

  # Used to determine correct partition (i.e. - `aws`, `aws-gov`, `aws-cn`, etc.)
  partition = data.aws_partition.current.partition
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.29.0"
  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  # Required for Karpenter role below
  # The enable_irsa flag will lead to the OIDC (OpenID Connect) provider being created
  # https://shipit.dev/posts/setting-up-eks-with-irsa-using-terraform.html
  enable_irsa = true

  eks_managed_node_group_defaults = {
    root_volume_type = var.eks_root_volume_type
  }

  # needed for karpenter
  # https://github.com/aws/karpenter/issues/1165#issuecomment-1023609340
  # https://github.com/aws/karpenter/issues/1165#issuecomment-1048105155
  cluster_security_group_additional_rules = {
    ingress_nodes_karpenter_ports_tcp = {
      description                = "Karpenter readiness"
      protocol                   = "tcp"
      from_port                  = 8443
      to_port                    = 8443
      type                       = "ingress"
      source_node_security_group = true
    }
  }
  node_security_group_additional_rules = {
    aws_lb_controller_webhook = {
      description                   = "Cluster API to AWS LB Controller webhook"
      protocol                      = "all"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  eks_managed_node_groups = {
    initial = {
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      instance_types = [for instance in var.eks_managed_node_groups_instance_types : instance]

      iam_role_additional_policies = [
        # Required by Karpenter
        "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    for role in var.roles : {
      rolearn  = role.arn,
      username = role.rolename,
      groups   = [role.groups]
    }
  ]

  aws_auth_users = [
    for user in var.users : {
      username = user.username,
      userarn  = user.arn,
      groups   = [user.groups]
    }
  ]

  tags = {
    Terraform   = "true"
    Terragrunt  = "true"
    Environment = "terragrunt-test"
    # Tag node group resources for Karpenter auto-discovery
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    "karpenter.sh/discovery" = local.cluster_name
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
