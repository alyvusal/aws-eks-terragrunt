variable "region" {}

variable "aws_profile" {}
variable "repository_name" {}

variable "users" {
  type = map(object({
    description = string
    username    = string
    arn         = string
    groups      = list(string)
  }))
}

variable "roles" {
  type = map(object({
    description = string
    rolename    = string
    arn         = string
    groups      = list(string)
  }))
}

# vpc
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "vpc_private_subnets" { type = list(string) }
variable "vpc_public_subnets" { type = list(string) }

# eks
variable "eks_root_volume_type" {}
variable "eks_cluster_base_name" {}
variable "eks_cluster_version" {}
variable "eks_managed_node_groups_instance_types" { type = list(string) }
