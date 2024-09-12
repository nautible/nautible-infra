provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    region  = "ap-northeast-1"
    key     = "nautible-dev-plugin.tfstate"
    encrypt = true
    # if you don't need to dynamodb tfstate lock, comment out this line.
    dynamodb_table = "nautible-dev-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.66.0"
    }
  }
}

# filter eks info
locals {
  target_eks = { for k, v in data.terraform_remote_state.nautible_aws_platform.outputs.eks :
  k => v if !contains(try(var.eks.excludes_cluster_names, []), v.cluster.name) }
}

module "nautible_plugin" {
  source      = "../../"
  project     = var.project
  environment = var.environment
  region      = var.region
  vpc = {
    vpc_id          = data.terraform_remote_state.nautible_aws_platform.outputs.vpc.vpc_id
    private_subnets = data.terraform_remote_state.nautible_aws_platform.outputs.vpc.private_subnets
  }
  eks             = local.target_eks
  auth            = var.auth
  kong_apigateway = var.kong_apigateway
  observation     = var.observation
}

data "terraform_remote_state" "nautible_aws_platform" {
  backend = "s3"
  config = {
    bucket = var.platform_tfstate.bucket
    region = var.platform_tfstate.region
    key    = var.platform_tfstate.key
  }
}
