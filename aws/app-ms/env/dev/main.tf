provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    bucket  = "nautible-dev-app-ms-tf-ap-northeast-1"
    region  = "ap-northeast-1"
    key     = "nautible-dev-app-ms.tfstate"
    encrypt = true
    # if you don't need to dynamodb tfstate lock, comment out this line.
    dynamodb_table = "nautible-dev-app-ms-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
}

module "nautible_aws_app" {
  source          = "../../"
  pjname          = var.pjname
  region          = var.region
  platform_pjname = data.terraform_remote_state.nautible_aws_platform.outputs.pjname
  vpc = {
    vpc_id            = data.terraform_remote_state.nautible_aws_platform.outputs.vpc_id
    public_subnets    = data.terraform_remote_state.nautible_aws_platform.outputs.public_subnets
    private_subnets   = data.terraform_remote_state.nautible_aws_platform.outputs.private_subnets
    private_zone_id   = data.terraform_remote_state.nautible_aws_platform.outputs.private_zone_id
    private_zone_name = data.terraform_remote_state.nautible_aws_platform.outputs.private_zone_name
  }
  eks = {
    node_security_group_id = data.terraform_remote_state.nautible_aws_platform.outputs.eks_node_security_group_id
    oidc_provider_arn      = data.terraform_remote_state.nautible_aws_platform.outputs.eks_oidc_provider_arn
  }
  order = var.order
}

data "terraform_remote_state" "nautible_aws_platform" {
  backend = "s3"
  config = {
    bucket = var.platform_tfstate.bucket
    region = var.platform_tfstate.region
    key    = var.platform_tfstate.key
  }
}
