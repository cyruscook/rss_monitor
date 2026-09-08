variable "name_prefix" {
  type     = string
  nullable = false
}

variable "clock_skew_seconds" {
  type     = number
  nullable = false
}

variable "feeds_table_arn" {
  type     = string
  nullable = false
}

variable "feeds_table_name" {
  type     = string
  nullable = false
}

variable "image_uri" {
  type     = string
  nullable = false
}

variable "lambda_architecture" {
  type     = string
  nullable = false
}

variable "timeout" {
  type     = number
  nullable = false
}

variable "queue_arn" {
  type     = string
  nullable = false
}

variable "queue_url" {
  type     = string
  nullable = false
}

variable "topic_arn" {
  type     = string
  nullable = false
}
