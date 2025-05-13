data "aws_caller_identity" "self" {}

resource "aws_dynamodb_table" "sequence" {
  name           = "Sequence"
  hash_key       = "Name"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "Name"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "sequence_initial_data" {
  table_name = aws_dynamodb_table.sequence.name
  hash_key   = aws_dynamodb_table.sequence.hash_key

  for_each = {
    item1 = {
      name = "Customer"
    }
    item2 = {
      name = "Stock"
    }
    item3 = {
      name = "Order"
    }
    item4 = {
      name = "StockAllocateHistory"
    }
  }

  item = <<ITEM
{
  "Name": {"S": "${each.value.name}"},
  "SequenceNumber": {"N": "0"}
}
ITEM

  lifecycle {
    ignore_changes = [item]
  }
}

resource "aws_eks_pod_identity_association" "app_ms_application_access_identity_association" {
  for_each = toset(var.eks_cluster_name)

  cluster_name    = each.value
  namespace       = "nautible-app-ms"
  service_account = "nautible-app-ms-sa"
  role_arn        = aws_iam_role.app_ms_application_access_role.arn
}

data "aws_iam_policy_document" "app_ms_application_access_policy_document" {
  statement {
    sid    = "DynamodbAccess"
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:PartiQLUpdate",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:ListStreams",
      "dynamodb:PartiQLSelect",
      "dynamodb:GetShardIterator",
      "dynamodb:PartiQLInsert",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PartiQLDelete"
    ]
    resources = ["*"]
  }

  statement {
    sid     = "SSMParameterAccess"
    effect  = "Allow"
    actions = ["ssm:GetParameter"]
    resources = [
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.self.account_id}:parameter/sample-*",
      "arn:aws:ssm:${var.region}:${data.aws_caller_identity.self.account_id}:parameter/nautible-*"
    ]
  }

  statement {
    sid    = "SQSAccess"
    effect = "Allow"
    actions = [
      "SQS:CreateQueue",
      "SQS:TagQueue",
      "SQS:GetQueueAttributes",
      "SQS:SetQueueAttributes",
      "SQS:SendMessage",
      "SQS:ReceiveMessage",
      "SQS:DeleteMessage"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SNSAccess"
    effect = "Allow"
    actions = [
      "SNS:ListTopics",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:CreateTopic",
      "SNS:Subscribe",
      "SNS:Publish",
      "SNS:TagResource"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "podidentity_access_role_document" {
  statement {
    effect = "Allow"
    actions = [
      "sts:TagSession",
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_ms_application_access_role" {
  name               = "${var.pjname}-app-ms-access-role"
  assume_role_policy = data.aws_iam_policy_document.podidentity_access_role_document.json
}

resource "aws_iam_policy" "app_ms_application_access_policy" {
  name   = "${var.pjname}-app-ms-application-access-policy"
  policy = data.aws_iam_policy_document.app_ms_application_access_policy_document.json
}

resource "aws_iam_role_policy_attachment" "app_ms_application_access_policy_attachment" {
  role       = aws_iam_role.app_ms_application_access_role.name
  policy_arn = aws_iam_policy.app_ms_application_access_policy.arn
}
