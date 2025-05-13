data "aws_caller_identity" "self" {}

resource "aws_eks_pod_identity_association" "auth_secret_access_identity_association" {
  for_each = toset(var.eks_cluster_name)

  cluster_name    = each.value
  namespace       = var.namespace
  service_account = "external-secrets"
  role_arn        = aws_iam_role.auth_secret_access_role.arn
}

data "aws_iam_policy_document" "auth_secret_access_role_document" {
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

data "aws_iam_policy_document" "auth_secret_access_policy_document" {

  statement {
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.self.account_id}:secret:*"
    ]
  }
}

resource "aws_iam_role" "auth_secret_access_role" {
  name               = "${var.pjname}-auth-secret-access-role"
  assume_role_policy = data.aws_iam_policy_document.auth_secret_access_role_document.json
}

resource "aws_iam_policy" "auth_secret_access_policy" {
  name   = "${var.pjname}-auth-secret-access-policy"
  policy = data.aws_iam_policy_document.auth_secret_access_policy_document.json
}

resource "aws_iam_role_policy_attachment" "auth_secret_access_policy_attachment" {
  role       = aws_iam_role.auth_secret_access_role.name
  policy_arn = aws_iam_policy.auth_secret_access_policy.arn
}
