module "ecr" {
  source                            = "terraform-aws-modules/ecr/aws"
  version                           = "1.4.0"
  repository_name                   = var.repository_name
  repository_read_write_access_arns = [for user in var.users : user.arn]

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Terragrunt  = "true"
    Environment = "terragrunt-test"
  }
}
