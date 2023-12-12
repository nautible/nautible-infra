provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    bucket  = "nautible-dev-plugin-tf-ap-northeast-1"
    region  = "ap-northeast-1"
    key     = "nautible-dev-backup.tfstate"
    encrypt = true
    # if you don't need to dynamodb tfstate lock, comment out this line.
    dynamodb_table = "nautible-dev-plugin-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30.0"
    }
  }
}

data "terraform_remote_state" "nautible_aws_platform" {
  backend = "s3"
  config = {
    bucket = var.platform_tfstate.bucket
    region = var.platform_tfstate.region
    key    = var.platform_tfstate.key
  }
}

# filter eks info
locals {
  target_eks = { for k, v in data.terraform_remote_state.nautible_aws_platform.outputs.eks :
  k => v if !contains(try(v.excludes_cluster_names, []), v.cluster.name) }
}

module "backup" {
  source                              = "../../"
  backup_bucket_name                  = var.backup_bucket_name
  eks_cluster_name_node_role_name_map = zipmap(values(local.target_eks).*.cluster.name, values(local.target_eks).*.node.role_name)
}