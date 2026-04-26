resource "aws_lambda_function" "lambda_function" {
  function_name = local.function_name
  role          = aws_iam_role.lambda_execution.arn
  package_type  = "Image"
  image_uri     = var.image_uri
  architectures = [var.lambda_architecture]
  timeout       = var.timeout
  memory_size   = 256

  environment {
    variables = {
      CLOCK_SKEW_SECONDS      = tostring(var.clock_skew_seconds)
      FEEDS_TABLE_NAME        = var.feeds_table_name
      FEED_QUEUE_URL          = var.queue_url
      NOTIFICATION_TOPIC_ARN  = var.topic_arn
      POWERTOOLS_SERVICE_NAME = var.name_prefix
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda_function,
    aws_iam_role_policy.lambda_execution,
  ]
}

resource "aws_lambda_event_source_mapping" "lambda_feed_queue" {
  event_source_arn        = var.queue_arn
  function_name           = aws_lambda_function.lambda_function.arn
  batch_size              = 10
  function_response_types = ["ReportBatchItemFailures"]
}

resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.lambda_function.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "lambda_public" {
  statement_id  = "AllowPublicFunctionInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "*"
}

resource "aws_lambda_permission" "lambda_public_url" {
  statement_id           = "AllowPublicFunctionUrlInvoke"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.lambda_function.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

resource "aws_lambda_permission" "scheduler_invoke_lambda" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "scheduler.amazonaws.com"
  source_arn    = "arn:aws:scheduler:${local.region}:${local.account_id}:schedule/*"
}
