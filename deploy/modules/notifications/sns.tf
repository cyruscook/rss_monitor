resource "aws_sns_topic" "messaging_notifications" {
  name = "${var.name_prefix}-notifications"
}

resource "aws_sns_topic_subscription" "email_sub" {
  for_each = { for sub in var.subscriptions : sha1(jsonencode([sub.protocol, sub.endpoint])) => sub }

  topic_arn = aws_sns_topic.messaging_notifications.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}
