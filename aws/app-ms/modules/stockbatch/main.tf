# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "ecr_stockbatch" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-stock-batch"
}
