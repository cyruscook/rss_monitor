output "lambda_function_url" {
  value = module.lambda.function_url
}

output "lambda_image_repository_url" {
  value = module.registry.repository_url
}
