resource "aws_scheduler_schedule" "schedule" {
  name                = var.name_prefix
  schedule_expression = var.schedule_expression

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 60
  }

  target {
    arn      = var.lambda_function_arn
    role_arn = aws_iam_role.scheduler_invoke_lambda.arn
    input = jsonencode({
      "detail-type" = "Scheduled Event"
      source        = "aws.scheduler"
    })
  }
}
