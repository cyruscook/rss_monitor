variable "name_prefix" {
  type     = string
  nullable = false
}

variable "lambda_function_arn" {
  type     = string
  nullable = false
}

variable "schedule_expression" {
  type     = string
  nullable = false
}
