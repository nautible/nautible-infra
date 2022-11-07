# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "ecr_examples_java" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-examples-java"
}

resource "aws_ecrpublic_repository" "ecr_examples_go" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-examples-go"
}

resource "aws_ecrpublic_repository" "ecr_examples_node" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-examples-node"
}

resource "aws_ecrpublic_repository" "ecr_examples_python" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-examples-python"
}
