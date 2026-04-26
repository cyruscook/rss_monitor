terraform {
  backend "s3" {}
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
