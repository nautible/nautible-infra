# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "ecr_payment_credit" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-payment-credit"
}

resource "aws_ecrpublic_repository" "ecr_payment" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-payment"
}

resource "aws_dynamodb_table" "payment" {
  name           = "Payment"
  hash_key       = "OrderNo"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "OrderNo"
    type = "S"
  }

  attribute {
    name = "OrderDate"
    type = "S"
  }

  attribute {
    name = "CustomerId"
    type = "N"
  }

  global_secondary_index {
    name            = "GSI-CustomerId"
    hash_key        = "CustomerId"
    range_key       = "OrderDate"
    write_capacity  = 1
    read_capacity   = 1
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "credit-payment" {
  name           = "CreditPayment"
  hash_key       = "AcceptNo"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "AcceptNo"
    type = "S"
  }
}

resource "aws_dynamodb_table" "payment-allocate-history" {
  name           = "PaymentAllocateHistory"
  hash_key       = "RequestId"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "RequestId"
    type = "S"
  }
}

resource "aws_sqs_queue" "payment_sqs_dapr_pubsub" {
  name = "nautible-app-ms-payment"
  tags = {
    "dapr-queue-name" = "nautible-app-ms-payment"
  }
}

resource "aws_sns_topic" "payment_sns_topic_payment_create" {
  name = "payment-create"

  tags = {
    "dapr-topic-name" = "payment-create"
  }
}

resource "aws_sns_topic" "payment_sns_topic_payment_reject_create" {
  name = "payment-reject-create"

  tags = {
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
