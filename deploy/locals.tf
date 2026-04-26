data "aws_ecr_image" "lambda_image" {
  repository_name = local.lambda_image_name
  image_tag       = var.lambda_image_tag
}

locals {
  lambda_image_name   = "rss-monitor"
  lambda_image_digest = data.aws_ecr_image.lambda_image.image_digest
  lambda_image_uri    = "${module.registry.repository_url}@${local.lambda_image_digest}"

  feed_processing_lambda_timeout = 60 * 3
}
