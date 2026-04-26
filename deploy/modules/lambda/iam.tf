resource "aws_iam_role" "lambda_execution" {
  name               = "${var.name_prefix}-lambda-execution"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_execution" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["${aws_cloudwatch_log_group.lambda_function.arn}:*"]
  }

  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
    ]
    resources = [var.feeds_table_arn]
  }

  statement {
    actions   = ["sqs:SendMessage"]
    resources = [var.queue_arn]
  }

  statement {
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
    resources = [var.queue_arn]
  }

  statement {
    actions   = ["sns:Publish"]
    resources = [var.topic_arn]
  }
}

resource "aws_iam_role_policy" "lambda_execution" {
  name   = "${var.name_prefix}-lambda-execution"
  role   = aws_iam_role.lambda_execution.id
  policy = data.aws_iam_policy_document.lambda_execution.json
}
