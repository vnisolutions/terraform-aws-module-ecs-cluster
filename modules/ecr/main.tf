### ------------------------------------------------------------------------
# ECR repositories
### ------------------------------------------------------------------------

resource "aws_ecr_repository" "repository" {
  for_each = toset(var.ecr_name)
  name     = each.value
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "iam_policy" {
  for_each   = toset(var.ecr_name)
  repository = each.value
  depends_on = [aws_ecr_repository.repository]
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Sid" : "LambdaECRImageCrossAccountRetrievalPolicy",
        "Effect" : "Allow",
        "Action" : [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer"
        ],
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  for_each   = toset(var.ecr_name)
  repository = each.value
  depends_on = [aws_ecr_repository.repository]
  policy = jsonencode({
    "rules" : [
      {
        "action" : {
          "type" : "expire"
        },
        "description" : "Keep last 30 images",
        "rulePriority" : 1,
        "selection" : {
          "countType" : "imageCountMoreThan",
          "tagStatus" : "any",
          "countNumber" : 30
        }
      }
    ]
  })
}
