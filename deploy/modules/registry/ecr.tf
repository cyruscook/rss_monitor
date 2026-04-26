resource "aws_ecr_repository" "registry_lambda_image" {
  name                 = var.image_name
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "registry_lambda_image" {
  repository = aws_ecr_repository.registry_lambda_image.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the last 10 Lambda images."
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      },
    ]
  })
}
