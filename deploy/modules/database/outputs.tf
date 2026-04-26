output "feeds_table_arn" {
  value = aws_dynamodb_table.data_feeds.arn
}

output "feeds_table_name" {
  value = aws_dynamodb_table.data_feeds.name
}
