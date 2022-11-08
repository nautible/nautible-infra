provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    # 通常のnautible設定
    #bucket  = "nautible-dev-platform-tf-ap-northeast-1"
    #region  = "ap-northeast-1"
    #key     = "nautible-dev-platform.tfstate"
    bucket  = "nautible-cloudarch-dev-platform-tf-us-east-1"
    region  = "us-east-1"
    key     = "nautible-cloudarch-dev-platform.tfstate"
    encrypt = true
    # if you don't need to dynamodb tfstate lock, comment out this line.
    # 通常のnautible設定
    #dynamodb_table = "nautible-dev-platform-tfstate-lock"
    dynamodb_table = "nautible-cloudarch-dev-platform-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
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
