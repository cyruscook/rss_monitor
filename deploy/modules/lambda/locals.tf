data "aws_caller_identity" "registry_current" {}
data "aws_region" "registry_current" {}
data "aws_partition" "current" {}
data "aws_service_principal" "lambda" {
  service_name = "lambda"
}
data "aws_service_principal" "scheduler" {
  service_name = "scheduler"
}

locals {
  account_id = data.aws_caller_identity.registry_current.account_id
  region     = data.aws_region.registry_current.region

  function_name = var.name_prefix
}
