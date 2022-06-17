resource "aws_sqs_queue" "kong_serverless_plugin_pubsub" {
  name = "kong-serverless-plugin-pubsub"
  tags = {
    "dapr-queue-name" = "kong-serverless-plugin-pubsub"
  }
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
