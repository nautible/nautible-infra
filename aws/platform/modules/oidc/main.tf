# OIDC Provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = var.oidc.url

  client_id_list = [
    "https://github.com/${var.oidc.github_organization}",
  ]

  thumbprint_list = ["${var.oidc.thumbprint_1}"]
}

# OIDC access role
resource "aws_iam_role" "oidc_role" {
  name = "${var.pjname}-oidc-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.oidc_provider.id}"
      },
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:${var.oidc.github_organization}/*"
          ]
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "oidc_policy" {
  name = "${aws_iam_role.oidc_role.name}-policy"
  role = "${aws_iam_role.oidc_role.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}