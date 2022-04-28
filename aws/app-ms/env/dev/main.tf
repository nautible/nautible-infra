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
  source                                 = "../../"
  pjname                                 = var.pjname
  region                                 = var.region
  platform_pjname                        = data.terraform_remote_state.nautible_aws_platform.outputs.pjname
  vpc_id                                 = data.terraform_remote_state.nautible_aws_platform.outputs.vpc_id
  public_subnets                         = data.terraform_remote_state.nautible_aws_platform.outputs.public_subnets
  private_subnets                        = data.terraform_remote_state.nautible_aws_platform.outputs.private_subnets
  private_zone_id                        = data.terraform_remote_state.nautible_aws_platform.outputs.private_zone_id
  private_zone_name                      = data.terraform_remote_state.nautible_aws_platform.outputs.private_zone_name
  eks_node_security_group_id             = data.terraform_remote_state.nautible_aws_platform.outputs.eks_node_security_group_id
  order_elasticache_node_type            = var.order_elasticache_node_type
  order_elasticache_parameter_group_name = var.order_elasticache_parameter_group_name
  order_elasticache_engine_version       = var.order_elasticache_engine_version
  order_elasticache_port                 = var.order_elasticache_port
}

data "terraform_remote_state" "nautible_aws_platform" {
  backend = "s3"
  config = {
    bucket = var.nautible_aws_platform_state_bucket
    region = var.nautible_aws_platform_state_region
    key    = var.nautible_aws_platform_state_key
  }
}
