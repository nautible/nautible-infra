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
      version = "~> 5.30.0"
    }
  }
}

# filter eks info
locals {
  target_eks = { for k, v in data.terraform_remote_state.nautible_aws_platform.outputs.eks :
  k => v if !contains(try(var.eks.excludes_cluster_names, []), v.cluster.name) }
}

module "nautible_aws_app" {
  source          = "../../"
  pjname          = var.pjname
  region          = var.region
  platform_pjname = data.terraform_remote_state.nautible_aws_platform.outputs.pjname
  vpc = {
    vpc_id            = data.terraform_remote_state.nautible_aws_platform.outputs.vpc.vpc_id
    public_subnets    = data.terraform_remote_state.nautible_aws_platform.outputs.vpc.public_subnets
    private_subnets   = data.terraform_remote_state.nautible_aws_platform.outputs.vpc.private_subnets
    private_zone_id   = data.terraform_remote_state.nautible_aws_platform.outputs.route53.private_zone_id
    private_zone_name = data.terraform_remote_state.nautible_aws_platform.outputs.route53.private_zone_name
  }
  eks       = local.target_eks
  order     = var.order
  productdb = var.productdb
}

data "terraform_remote_state" "nautible_aws_platform" {
  backend = "s3"
  config = {
    bucket = var.platform_tfstate.bucket
    region = var.platform_tfstate.region
    key    = var.platform_tfstate.key
  }
}
