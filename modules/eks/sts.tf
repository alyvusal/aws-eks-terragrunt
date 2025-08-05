data "aws_caller_identity" "current" {}

# https://github.com/kubernetes-sigs/aws-iam-authenticator#1-create-an-iam-role
resource "aws_iam_role" "kubernetes_admin" {
  name = "KubernetesAdmin"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      { "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {}
      }
    ]
  })
}
