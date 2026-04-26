variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "profile" {
  type    = string
  default = null
}

variable "project_name" {
  type    = string
  default = "rss-monitor"
}

variable "admin_email" {
  type = string
}

variable "lambda_architecture" {
  type    = string
  default = "arm64"
}

variable "lambda_image_tag" {
  type    = string
  default = "latest"
}
