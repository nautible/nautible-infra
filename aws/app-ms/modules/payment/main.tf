# ecrpublic_repository can only be used with us-east-1 region.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "ecr_payment_cash" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-payment-cash"
}

resource "aws_ecrpublic_repository" "ecr_payment_convenience" {
  provider        = aws.us_east_1
  repository_name ="nautible-app-ms-payment-convenience"
}

resource "aws_ecrpublic_repository" "ecr_payment_credit" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-payment-credit"
}

resource "aws_ecrpublic_repository" "ecr_payment_bff" {
  provider        = aws.us_east_1
  repository_name = "nautible-app-ms-payment-bff"
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
