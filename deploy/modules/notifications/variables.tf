variable "name_prefix" {
  type     = string
  nullable = false
}

variable "subscriptions" {
  type = list(object({
    protocol : string
    endpoint : string
  }))
  nullable = false
}
