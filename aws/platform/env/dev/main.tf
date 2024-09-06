provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    bucket  = "nautible-dev-platform-tf-ap-northeast-1"
    region  = "ap-northeast-1"
    key     = "nautible-dev-platform.tfstate"
    encrypt = true
    # if you don't need to dynamodb tfstate lock, comment out this line.
    dynamodb_table = "nautible-dev-platform-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.57.0"
    }
  }
}

module "nautible_aws_platform" {
  source               = "../../"
  pjname               = var.pjname
  region               = var.region
  create_iam_resources = var.create_iam_resources
  vpc                  = var.vpc
  eks                  = var.eks
  cloudfront           = var.cloudfront
  oidc                 = var.oidc
}
