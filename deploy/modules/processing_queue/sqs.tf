resource "aws_sqs_queue" "messaging_feed_dlq" {
  name                      = "${var.name_prefix}-feed-dlq"
  message_retention_seconds = 60 * 60 * 24 * 7
}

resource "aws_sqs_queue" "messaging_feed_queue" {
  name                       = "${var.name_prefix}-feed-queue"
  visibility_timeout_seconds = var.visibility_timeout

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.messaging_feed_dlq.arn
    maxReceiveCount     = 3
  })
}
