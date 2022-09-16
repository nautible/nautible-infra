data "aws_caller_identity" "self" {}

resource "aws_iam_role" "container_scan_secret_access_role" {
  name = "${var.pjname}-container-scan-secret-access-role"

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

resource "aws_iam_role_policy" "container_scan_secret_access_role_policy" {
  name = "${var.pjname}-container-scan-secret-access-role-policy"
  role = aws_iam_role.container_scan_secret_access_role.id

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
          "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.self.account_id}:secret:nautible-plugin-container-scan*"
        ]
      }
    ]
  })
}
