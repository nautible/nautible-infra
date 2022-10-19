resource "aws_sqs_queue" "kong_serverless_plugin_pubsub" {
  name                      = "kong-serverless-plugin"
  message_retention_seconds = var.kong_apigateway.sqs.message_retention_seconds

  tags = {
    "dapr-queue-name" = "kong-serverless-plugin"
  }
}

resource "aws_sqs_queue_policy" "kong_serverless_plugin_pubsub_policy" {
  queue_url = aws_sqs_queue.kong_serverless_plugin_pubsub.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "sqspolicy",
    Statement = [
      {
        Sid       = "First",
        Effect    = "Allow",
        Principal = "*",
        Action    = "sqs:SendMessage",
        Resource  = "${aws_sqs_queue.kong_serverless_plugin_pubsub.arn}",
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = "${aws_sns_topic.kong_root_request_topic.arn}"
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic" "kong_root_request_topic" {
  name = "kong-root-request"

  tags = {
    "dapr-topic-name" = "kong-root-request"
  }
}

resource "aws_sns_topic_subscription" "kong_serverless_plugin_topic_subscription" {
  topic_arn = aws_sns_topic.kong_root_request_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.kong_serverless_plugin_pubsub.arn
}
