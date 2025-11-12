data "aws_caller_identity" "self" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "pod_access_role_document" {
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