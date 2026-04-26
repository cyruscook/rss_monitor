variable "name_prefix" {
  type = string
}

variable "clock_skew_seconds" {
  type = number
}

variable "feeds_table_arn" {
  type = string
}

variable "feeds_table_name" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "lambda_architecture" {
  type = string
}

variable "timeout" {
  type = number
}

variable "queue_arn" {
  type = string
}

variable "queue_url" {
  type = string
}

variable "topic_arn" {
  type = string
}
