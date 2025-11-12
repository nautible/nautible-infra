provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    region  = "ap-northeast-1"
    key     = "nautible-dev-app-examples.tfstate"
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

module "nautible_aws_app_examples" {
  source = "../../"
  region = var.region
}
