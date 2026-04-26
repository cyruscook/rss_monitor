data "aws_caller_identity" "registry_current" {}
data "aws_region" "registry_current" {}

locals {
  account_id = data.aws_caller_identity.registry_current.account_id
  region     = data.aws_region.registry_current.name

  function_name = var.name_prefix
}
