data "aws_availability_zones" "available" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "3.14.4"
  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = [for subnet in var.vpc_private_subnets : subnet]
  public_subnets       = [for subnet in var.vpc_public_subnets : subnet]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.cluster_name
  }

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    Terraform                                     = "true"
    Terragrunt                                    = "true"
    Environment                                   = "terragrunt-test"
  }
}
