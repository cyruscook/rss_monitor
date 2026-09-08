variable "name_prefix" {
  type     = string
  nullable = false
}

variable "dlq_name" {
  type     = string
  nullable = false
}

variable "lambda_function_name" {
  type     = string
  nullable = false
}

variable "topic_arn" {
  type     = string
  nullable = false
}
