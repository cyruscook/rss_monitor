output "dlq_arn" {
  value = aws_sqs_queue.messaging_feed_dlq.arn
}

output "dlq_name" {
  value = aws_sqs_queue.messaging_feed_dlq.name
}

output "feed_queue_arn" {
  value = aws_sqs_queue.messaging_feed_queue.arn
}

output "feed_queue_url" {
  value = aws_sqs_queue.messaging_feed_queue.url
}
