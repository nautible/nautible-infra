# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "ecr_delivery" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-delivery"
}

resource "aws_dynamodb_table" "delivery" {
  name           = "Delivery"
  hash_key       = "DeliveryNo"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "DeliveryNo"
    type = "S"
  }

}
