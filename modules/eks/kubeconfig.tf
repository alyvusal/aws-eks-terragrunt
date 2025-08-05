locals {
  # https://github.com/kubernetes-sigs/aws-iam-authenticator#1-create-an-iam-role
  kubeconfig = templatefile("templates/kubeconfig.tpl", {
    kubeconfig_name                   = module.eks.cluster_id
    endpoint                          = data.aws_eks_cluster.cluster.endpoint
    cluster_auth_base64               = data.aws_eks_cluster.cluster.certificate_authority.0.data
    aws_authenticator_command         = "aws"
    aws_authenticator_command_args    = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    aws_authenticator_additional_args = ["--region", var.region]
    aws_authenticator_env_variables   = {}

    aws_authenticator_command2         = "aws-iam-authenticator"
    aws_authenticator_command_args2    = ["token", "-i", data.aws_eks_cluster.cluster.name]
    aws_authenticator_additional_args2 = []
  })
}

output "kubeconfig" { value = local.kubeconfig }
