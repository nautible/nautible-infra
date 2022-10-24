provider "aws" {
  region = var.region
}

terraform {
  # fix folloing value
  backend "s3" {
    bucket  = "nautible-dev-app-examples-tf-ap-northeast-1"
    region  = "ap-northeast-1"
    key     = "nautible-dev-app-examples.tfstate"
    encrypt = true
    # if you don't need to dynamodb tfstate lock, comment out this line.
    dynamodb_table = "nautible-dev-app-examples-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
}

module "nautible_aws_app_examples" {
  source = "../../"
  region = var.region
}
