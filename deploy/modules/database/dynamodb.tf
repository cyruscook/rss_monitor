resource "aws_dynamodb_table" "data_feeds" {
  name         = "${var.name_prefix}-feeds"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "feed_url"

  attribute {
    name = "feed_url"
    type = "S"
  }
}
