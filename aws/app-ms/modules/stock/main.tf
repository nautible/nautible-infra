# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "ecr_stock" {
  provider        = aws.us_east_1
  repository_name =  "nautible-app-stock"
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
  # dapr 1.0.0-rc2: name must be app name hash value
  name = "e8798c501adf823712ec3eab9184ff35aa6afa985b054c5fea36c06906fbfe34"
  tags = {
    # dapr 1.0.0-rc2: tag must be folling value
    "dapr-queue-name" = "nautible-app-stock"
  }
}

resource "aws_sns_topic" "stock_sns_topic_stock_reserve_allocate" {
  # dapr 1.0.0-rc2: name must be topic name hash value
  name = "121218fdb336f17cb1a1e62cbabb4bcffd7056b04f265e3087e94fd6bb3be723"

  tags = {
    # dapr 1.0.0-rc2: tag must be folling value
    "dapr-topic-name" = "stock-reserve-allocate"
  }
}

resource "aws_sns_topic" "stock_sns_topic_stock_approve_allocate" {
  # dapr 1.0.0-rc2: name must be topic name hash value
  name = "f4878ef98191c6a25b56e792e44630a5d867dd602d33804624d0548d99aab953"

  tags = {
    # dapr 1.0.0-rc2: tag must be folling value
    "dapr-topic-name" = "stock-approve-allocate"
  }
}

resource "aws_sns_topic" "stock_sns_topic_stock_reject_allocate" {
  # dapr 1.0.0-rc2: name must be topic name hash value
  name = "529cb96d495da6bb8438248060e9fad7032107bebc1a62063d642552dd348f0c"

  tags = {
    # dapr 1.0.0-rc2: tag must be folling value
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
