include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = "${get_terragrunt_dir()}/../../modules/common.hcl"
}

# --------------- VARIABLES ---------------

inputs = {
  # aws regions
  region          = "us-east-1" # North Virginia
  aws_profile     = "terraform-cli"
  repository_name = "terragrunt-ecr"

  # eks
  eks_cluster_version   = "1.22"
  eks_cluster_base_name = "terragrunt-test"
  eks_root_volume_type  = "gp2"

  # vpc
  vpc_name                               = "terragrunt"
  vpc_cidr                               = "10.0.0.0/16"
  vpc_private_subnets                    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  vpc_public_subnets                     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  eks_managed_node_groups_instance_types = ["t3.small"]

  # users
  users = {
    u_terraform = {
      description = "Terraform CLI"
      username    = "terraform"
      arn         = "arn:aws:iam::314115176041:user/terraform-cli"
      groups      = ["system:masters"]
    },
    u_fulladmin = {
      description = "Full Admin"
      username    = "fulladmin"
      arn         = "arn:aws:iam::314115176041:user/full_admin"
      groups      = ["system:masters"]
    }
  }

  roles = {
    r_k8sadmin = {
      description = "Kubernetes Admin"
      rolename    = "KubernetesAdmin"
      arn         = "arn:aws:iam::314115176041:role/KubernetesAdmin"
      groups      = ["system:masters"]
    }
  }
}
