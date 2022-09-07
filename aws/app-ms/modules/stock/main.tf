# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "ecr_stock" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-stock"
}

resource "aws_dynamodb_table" "stock" {
  name           = "Stock"
  hash_key       = "Id"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "Id"
    type = "N"
  }

}

resource "aws_dynamodb_table" "stock_allocate_history" {
  name           = "StockAllocateHistory"
  hash_key       = "RequestId"
  range_key      = "ProductId"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "RequestId"
    type = "S"
  }

  attribute {
    name = "ProductId"
    type = "N"
  }

}

resource "aws_sqs_queue" "stock_sqs_dapr_pubsub" {
  name = "nautible-app-ms-stock"
  tags = {
    "dapr-queue-name" = "nautible-app-ms-stock"
  }
}

resource "aws_sns_topic" "stock_sns_topic_stock_reserve_allocate" {
  name = "stock-reserve-allocate"

  tags = {
    "dapr-topic-name" = "stock-reserve-allocate"
  }
}

resource "aws_sns_topic" "stock_sns_topic_stock_approve_allocate" {
  name = "stock-approve-allocate"

  tags = {
    "dapr-topic-name" = "stock-approve-allocate"
  }
}

resource "aws_sns_topic" "stock_sns_topic_stock_reject_allocate" {
  name = "stock-reject-allocate"

  tags = {
    "dapr-topic-name" = "stock-reject-allocate"
  }
}

resource "aws_sns_topic_subscription" "stock_topic_subscription_stock_reserve_allocate" {
  topic_arn = aws_sns_topic.stock_sns_topic_stock_reserve_allocate.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.stock_sqs_dapr_pubsub.arn
}

resource "aws_sns_topic_subscription" "stock_topic_subscription_stock_approve_allocate" {
  topic_arn = aws_sns_topic.stock_sns_topic_stock_approve_allocate.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.stock_sqs_dapr_pubsub.arn
}

resource "aws_sns_topic_subscription" "stock_topic_subscription_stock_reject_allocate" {
  topic_arn = aws_sns_topic.stock_sns_topic_stock_reject_allocate.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.stock_sqs_dapr_pubsub.arn
}
