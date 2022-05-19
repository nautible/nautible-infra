# OIDC Provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = var.oidc.url
  client_id_list = var.oidc.client_id_list
  thumbprint_list = var.oidc.thumbprint_list
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
  role = aws_iam_role.oidc_role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:GetServiceBearerToken",
        "ecr:GetAuthorizationToken",
        "ecr-public:GetAuthorizationToken",
        "ecr:GetRepositoryPolicy",
        "ecr-public:GetRepositoryPolicy",
        "ecr:Describe*",
        "ecr-public:Describe*",
        "ecr:GetRepositoryCatalogData",
        "ecr-public:GetRepositoryCatalogData",
        "ecr:GetRegistryCatalogData",
        "ecr-public:GetRegistryCatalogData",
        "ecr:BatchCheckLayerAvailability",
        "ecr-public:BatchCheckLayerAvailability",
        "ecr:InitiateLayerUpload",
        "ecr-public:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr-public:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr-public:CompleteLayerUpload",
        "ecr:PutImage",
        "ecr-public:PutImage"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}