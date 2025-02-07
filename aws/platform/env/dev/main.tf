provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    region  = "ap-northeast-1"
    key     = "nautible-dev-platform.tfstate"
    encrypt = true
    # if you don't need to dynamodb tfstate lock, comment out this line.
    dynamodb_table = "nautible-dev-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }
}

module "nautible_aws_platform" {
  source               = "../../"
  project              = var.project
  environment          = var.environment
  region               = var.region
  create_iam_resources = var.create_iam_resources
  vpc                  = var.vpc
  eks                  = var.eks
  cloudfront           = var.cloudfront
  oidc                 = var.oidc
  github_organization  = var.github_organization
}
