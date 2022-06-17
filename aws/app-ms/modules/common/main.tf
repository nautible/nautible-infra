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

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "Dynamodb",
        "Action": [
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
        "Effect": "Allow",
        "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": "ssm:GetParameter",
          "Resource": "arn:aws:ssm:*:${data.aws_caller_identity.self.account_id}:parameter/sample-*"
      },
      {
          "Effect": "Allow",
          "Action": "ssm:GetParameter",
          "Resource": "arn:aws:ssm:*:${data.aws_caller_identity.self.account_id}:parameter/nautible-*"
      },
      {
          "Effect": "Allow",
          "Action": ["SQS:SendMessage", "SQS:SendMessageBatch", "SQS:ReceiveMessage", "SQS:DeleteMessage"],
          "Resource": "*"
      },
      {
          "Sid": "DaprPubsubSqs",
          "Effect": "Allow",
          "Action": ["SQS:CreateQueue","SQS:SendMessage", "SQS:SendMessageBatch", "SQS:ReceiveMessage","SQS:DeleteMessage","SQS:DeleteMessageBatch","SQS:GetQueueAttributes","SQS:SetQueueAttributes","SQS:TagQueue"],
          "Resource": "*"
      },
      {
          "Sid": "DaprPubsubSns",
          "Effect": "Allow",
          "Action": ["SNS:ListTopics","SNS:GetTopicAttributes","SNS:CreateTopic","SNS:Subscribe", "SNS:Publish","SNS:TagResource"],
          "Resource": "*"
      }
    ]
  }
  EOF
}

# access policy from GithubActions
resource "aws_iam_user" "git" {
  name = "gh-user"
}

resource "aws_iam_user_policy" "gh_user_ecr_policy" {
  name = "ecr-pushpull-policy"
  user = aws_iam_user.git.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowPushPull",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr-public:GetAuthorizationToken",
                "ecr-public:BatchCheckLayerAvailability",
                "ecr-public:PutImage",
                "ecr-public:InitiateLayerUpload",
                "ecr-public:UploadLayerPart",
                "ecr-public:CompleteLayerUpload",
                "sts:GetServiceBearerToken"
            ],
            "Resource":"*"
        }
    ]
}
EOF
}

resource "aws_iam_user_policy" "gh_user_s3_policy" {
  name = "s3-sync-policy"
  user = aws_iam_user.git.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "AllowS3Sync",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource":"*"
        }
    ]
}
EOF
}

# access policy from GithubActions
resource "aws_iam_user" "sqs_message" {
  name = "sqs-message"
}

resource "aws_iam_user_policy" "sqs_message_policy" {
  name = "sqs-message-policy"
  user = aws_iam_user.sqs_message.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["SQS:Get*", "SQS:SendMessage", "SQS:ReceiveMessage", "SQS:DeleteMessage"],
            "Resource": "*"
        }
    ]
}
EOF
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