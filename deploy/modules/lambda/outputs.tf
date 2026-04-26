output "function_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "function_name" {
  value = aws_lambda_function.lambda_function.function_name
}

output "function_url" {
  value = aws_lambda_function_url.lambda_url.function_url
}
