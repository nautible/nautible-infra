# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "ecr_customer" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-customer"
}

resource "aws_dynamodb_table" "customer" {
  name           = "Customer"
  hash_key       = "Id"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "Id"
    type = "N"
  }

}