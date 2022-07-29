provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    bucket  = "nautible-dev-plugin-tf-ap-northeast-1"
    region  = "ap-northeast-1"
    key     = "nautible-dev-plugin.tfstate"
    encrypt = true
    # if you don't need to dynamodb tfstate lock, comment out this line.
    dynamodb_table = "nautible-dev-plugin-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
}

module "nautible_plugin" {
  source                     = "../../"
  pjname                     = var.pjname
  region                     = var.region
  vpc_id                     = data.terraform_remote_state.nautible_aws_platform.outputs.vpc_id
  private_subnets            = data.terraform_remote_state.nautible_aws_platform.outputs.private_subnets
  eks_node_security_group_id = data.terraform_remote_state.nautible_aws_platform.outputs.eks_node_security_group_id
  eks_oidc_provider_arn      = data.terraform_remote_state.nautible_aws_platform.outputs.eks_oidc_provider_arn
  auth_variables             = var.auth_variables
  kong_apigateway_variables  = var.kong_apigateway_variables
}

data "terraform_remote_state" "nautible_aws_platform" {
  backend = "s3"
  config = {
    bucket = var.nautible_aws_platform_state_bucket
    region = var.nautible_aws_platform_state_region
    key    = var.nautible_aws_platform_state_key
  }
}
