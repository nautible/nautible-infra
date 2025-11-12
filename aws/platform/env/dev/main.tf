provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    region  = "ap-northeast-1"
    key     = "nautible-dev-platform.tfstate"
    encrypt = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

module "nautible_aws_platform" {
  source               = "../../"
  project              = var.project
  environment          = var.environment
  region               = var.region
  create_iam_resources = var.create_iam_resources
  vpc                  = var.vpc
  eks_mode             = var.eks_mode
  eks_nodegroup        = var.eks_nodegroup
  eks_automode         = var.eks_automode
  cloudfront           = var.cloudfront
  oidc                 = var.oidc
  github_organization  = var.github_organization
}
