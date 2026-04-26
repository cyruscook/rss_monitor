resource "aws_cloudwatch_metric_alarm" "monitoring_dlq_visible_messages" {
  alarm_name          = "${var.name_prefix}-dlq-visible-messages"
  alarm_description   = "RSS feed was not processed"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  actions_enabled     = true
  alarm_actions       = [var.topic_arn]

  dimensions = {
    QueueName = var.dlq_name
  }
}

resource "aws_cloudwatch_metric_alarm" "monitoring_lambda_errors" {
  alarm_name          = "${var.name_prefix}-lambda-errors"
  alarm_description   = "RSS monitor Lambda invocation failed"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  actions_enabled     = true
  alarm_actions       = [var.topic_arn]

  dimensions = {
    FunctionName = var.lambda_function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "monitoring_scheduler_invocation_dropped" {
  alarm_name          = "${var.name_prefix}-scheduler-invocation-dropped"
  alarm_description   = "EventBridge Scheduler exhausted retries invoking the RSS monitor target"
  namespace           = "AWS/Scheduler"
  metric_name         = "InvocationDroppedCount"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  actions_enabled     = true
  alarm_actions       = [var.topic_arn]

  dimensions = {
    ScheduleGroup = "default"
  }
}
