variable "aws_region" {
  type     = string
  default  = "eu-west-1"
  nullable = false
}

variable "profile" {
  type     = string
  default  = null
  nullable = true
}

variable "project_name" {
  type     = string
  default  = "rss-monitor"
  nullable = false
}

variable "admin_email" {
  type     = string
  nullable = false
}

variable "lambda_architecture" {
  type     = string
  default  = "arm64"
  nullable = false
}

variable "lambda_image_tag" {
  type     = string
  default  = "latest"
  nullable = false
}
