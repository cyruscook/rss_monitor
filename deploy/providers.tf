terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }
}
provider "aws" {
  region  = var.aws_region
  profile = var.profile

  default_tags {
    tags = {
      Project = "rss-monitor"
    }
  }
}
