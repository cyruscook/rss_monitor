output "repository_arn" {
  value = aws_ecr_repository.registry_lambda_image.arn
}

output "repository_name" {
  value = aws_ecr_repository.registry_lambda_image.name
}

output "repository_url" {
  value = aws_ecr_repository.registry_lambda_image.repository_url
}
