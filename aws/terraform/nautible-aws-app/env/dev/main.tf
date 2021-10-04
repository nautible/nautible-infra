provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    bucket  = "nautible-aws-app-dev-tf-ap-northeast-1"
    region  = "ap-northeast-1"
    key     = "nautible-aws-app-dev.tfstate"
    encrypt = true
    # if you don't need to dynamodb tfstate lock, comment out this line.
    dynamodb_table = "nautible-aws-app-dev-tfstate-lock"
  }
}

module "nautible_aws_app" {
  source                                 = "../../"
  pjname                                 = var.pjname
  region                                 = var.region
  vpc_id                                 = data.terraform_remote_state.nautible_aws_platform.outputs.vpc_id
  public_subnets                         = data.terraform_remote_state.nautible_aws_platform.outputs.public_subnets
  private_subnets                        = data.terraform_remote_state.nautible_aws_platform.outputs.private_subnets
  eks_worker_iam_role_name               = data.terraform_remote_state.nautible_aws_platform.outputs.eks_worker_iam_role_name
  eks_cluster_security_group_id          = data.terraform_remote_state.nautible_aws_platform.outputs.eks_cluster_primary_security_group_id
  private_zone_id                        = data.terraform_remote_state.nautible_aws_platform.outputs.private_zone_id
  private_zone_name                      = data.terraform_remote_state.nautible_aws_platform.outputs.private_zone_name
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
