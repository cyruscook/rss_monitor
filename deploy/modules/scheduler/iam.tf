data "aws_service_principal" "scheduler" {
  service_name = "scheduler"
}

resource "aws_iam_role" "scheduler_invoke_lambda" {
  name               = "${var.name_prefix}-invoke-lambda"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
}

data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [data.aws_service_principal.scheduler.name]
    }
  }
}

data "aws_iam_policy_document" "scheduler_invoke_lambda" {
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = [var.lambda_function_arn]
  }
}

resource "aws_iam_role_policy" "scheduler_invoke_lambda" {
  name   = "${var.name_prefix}-invoke-lambda"
  role   = aws_iam_role.scheduler_invoke_lambda.id
  policy = data.aws_iam_policy_document.scheduler_invoke_lambda.json
}
