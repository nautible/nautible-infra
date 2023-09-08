provider "aws" {
  region = data.terraform_remote_state.nautible_aws_platform.outputs.region
}

terraform {
  # fix folloing value
  backend "s3" {
    # bucket  = "nautible-dev-platform-tf-ap-northeast-1"
    # region  = "ap-northeast-1"
    # key     = "nautible-dev-platform.tfstate"
    # encrypt = true
    # # if you don't need to dynamodb tfstate lock, comment out this line.
    # dynamodb_table = "nautible-dev-platform-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.61.0"
    }
  }
}

module "nautible_aws_cluster" {
  source               = "../../"
  pjname               = data.terraform_remote_state.nautible_aws_platform.outputs.pjname
  region               = data.terraform_remote_state.nautible_aws_platform.outputs.region
  create_iam_resources = data.terraform_remote_state.nautible_aws_platform.outputs.create_iam_resources
  vpc_cidr             = data.terraform_remote_state.nautible_aws_platform.outputs.vpc_cidr
  vpc_id               = data.terraform_remote_state.nautible_aws_platform.outputs.vpc.vpc_id
  public_subnets       = data.terraform_remote_state.nautible_aws_platform.outputs.vpc.public_subnets
  private_subnets      = data.terraform_remote_state.nautible_aws_platform.outputs.vpc.private_subnets
  group                = var.group
  eks                  = var.eks
}

data "terraform_remote_state" "nautible_aws_platform" {
  backend = "s3"
  config = {
    bucket = var.platform_tfstate.bucket
    region = var.platform_tfstate.region
    key    = var.platform_tfstate.key
  }
}