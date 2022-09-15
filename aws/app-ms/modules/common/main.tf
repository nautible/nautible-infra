# policy for nautible app service.
resource "random_id" "app_policy_random" {
  byte_length = 8
}

data "aws_caller_identity" "self" {}

data "aws_iam_role" "eks_node_role" {
  name = "${var.platform_pjname}-AmazonEKSNodeRole"
}

resource "aws_iam_role_policy" "app_policy" {
  name = "${var.pjname}-eks-app-policy-${random_id.app_policy_random.dec}"
  role = data.aws_iam_role.eks_node_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "Dynamodb",
        Action = [
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
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Resource = "arn:aws:secretsmanager:*:${data.aws_caller_identity.self.account_id}:secret:nautible-*"
      },
      {
        Effect   = "Allow",
        Action   = "ssm:GetParameter",
        Resource = "arn:aws:ssm:*:${data.aws_caller_identity.self.account_id}:parameter/sample-*"
      },
      {
        Effect   = "Allow",
        Action   = "ssm:GetParameter",
        Resource = "arn:aws:ssm:*:${data.aws_caller_identity.self.account_id}:parameter/nautible-*"
      },
      {
        Effect   = "Allow",
        Action   = ["SQS:SendMessage", "SQS:SendMessageBatch", "SQS:ReceiveMessage", "SQS:DeleteMessage"],
        Resource = "*"
      },
      {
        Sid      = "DaprPubsubSqs",
        Effect   = "Allow",
        Action   = ["SQS:ChangeMessageVisibility", "SQS:CreateQueue", "SQS:SendMessage", "SQS:SendMessageBatch", "SQS:ReceiveMessage", "SQS:DeleteMessage", "SQS:DeleteMessageBatch", "SQS:GetQueueAttributes", "SQS:GetQueueUrl", "SQS:SetQueueAttributes", "SQS:TagQueue"],
        Resource = "*"
      },
      {
        Sid      = "DaprPubsubSns",
        Effect   = "Allow",
        Action   = ["SNS:ListTopics", "SNS:ListSubscriptionsByTopic", "SNS:GetTopicAttributes", "SNS:CreateTopic", "SNS:Subscribe", "SNS:Publish", "SNS:TagResource"],
        Resource = "*"
      }
    ]
  })
}

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

resource "aws_iam_role" "app_secret_access_role" {
  name = "${var.pjname}-app-secret-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRoleWithWebIdentity",
        Principal = {
          Federated = "${var.eks_oidc_provider_arn}"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "app_secret_access_role_policy" {
  name = "${var.pjname}-app-secret-access-role-policy"
  role = aws_iam_role.app_secret_access_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.self.account_id}:secret:nautible-app-ms-*"
        ]
      }
    ]
  })
}
