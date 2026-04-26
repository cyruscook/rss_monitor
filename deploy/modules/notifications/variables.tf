variable "name_prefix" {
  type = string
}

variable "subscriptions" {
  type = list(object({
    protocol : string
    endpoint : string
  }))
}
