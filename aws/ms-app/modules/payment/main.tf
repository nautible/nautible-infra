# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "ecr_payment_cash" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-payment-cash"
}

resource "aws_ecrpublic_repository" "ecr_payment_convenience" {
  provider        = aws.us_east_1
  repository_name ="nautible-app-payment-convenience"
}

resource "aws_ecrpublic_repository" "ecr_payment_credit" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-payment-credit"
}

resource "aws_ecrpublic_repository" "ecr_payment_bff" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-payment-bff"
}

resource "aws_dynamodb_table" "payment" {
  name           = "Payment"
  hash_key       = "PaymentNo"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "PaymentNo"
    type = "S"
  }

  attribute {
    name = "OrderNo"
    type = "S"
  }

  attribute {
    name = "CustomerId"
    type = "N"
  }

  global_secondary_index {
    name            = "GSI-CustomerId"
    hash_key        = "CustomerId"
    range_key       = "OrderNo"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
  }
}

resource "aws_sqs_queue" "payment_sqs_dapr_pubsub" {
  # dapr 1.0.0-rc2: name must be app name hash value
  name = "9004506a6283f1c25e52430ea01f3f860d114a4efc1ae4f972e530f0e31104e9"
  tags = {
    # dapr 1.0.0-rc2: tag must be folling value
    "dapr-queue-name" = "nautible-app-payment"
  }
}

resource "aws_sns_topic" "payment_sns_topic_payment_create" {
  # dapr 1.0.0-rc2: name must be topic name hash value
  name = "a75813a18cfe19d79d6ba256676549a8fe9663f4077c071eb4318f00e93e570d"

  tags = {
    # dapr 1.0.0-rc2: tag must be folling value
    "dapr-topic-name" = "payment-create"
  }
}

resource "aws_sns_topic" "payment_sns_topic_payment_reject_create" {
  # dapr 1.0.0-rc2: name must be topic name hash value
  name = "229d389f3c463a6592a9a05ca4b988571670c378650dd4a2aec9bf4b815727a5"

  tags = {
    # dapr 1.0.0-rc2: tag must be folling value
    "dapr-topic-name" = "payment-reject-create"
  }
}

resource "aws_sns_topic_subscription" "payment_topic_subscription_payment_create" {
  topic_arn = aws_sns_topic.payment_sns_topic_payment_create.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.payment_sqs_dapr_pubsub.arn
}

resource "aws_sns_topic_subscription" "payment_topic_subscription_payment_reject_create" {
  topic_arn = aws_sns_topic.payment_sns_topic_payment_reject_create.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.payment_sqs_dapr_pubsub.arn
}
