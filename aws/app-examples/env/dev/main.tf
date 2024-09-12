provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    region  = "ap-northeast-1"
    key     = "nautible-dev-app-examples.tfstate"
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

module "nautible_aws_app_examples" {
  source = "../../"
  region = var.region
}
