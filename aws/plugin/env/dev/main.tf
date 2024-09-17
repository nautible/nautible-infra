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
    # デフォルトではplatformと同じバケットを使用しているので、自身のバケット、リージョンを指定する
    # 異なるバックエンドを利用する場合は個別に指定してください
    bucket = local.backend_config.backend.config.bucket
    region = local.backend_config.backend.config.region
    key    = var.platform_tfstate
  }
}
