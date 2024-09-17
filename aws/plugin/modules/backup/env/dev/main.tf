provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    region  = "ap-northeast-1"
    key     = "nautible-dev-plugin-backup.tfstate"
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

# filter eks info
locals {
  target_eks = { for k, v in data.terraform_remote_state.nautible_aws_platform.outputs.eks :
  k => v if !contains(try(v.excludes_cluster_names, []), v.cluster.name) }
}

module "backup" {
  source                              = "../../"
  project                             = var.project
  environment                         = var.environment
  region                              = var.region
  eks_cluster_name_node_role_name_map = zipmap(values(local.target_eks).*.cluster.name, values(local.target_eks).*.node.role_name)
}
