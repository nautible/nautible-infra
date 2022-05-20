# OIDC Provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = var.oidc.url
  client_id_list = var.oidc.client_id_list
  thumbprint_list = var.oidc.thumbprint_list
}

resource "aws_iam_role" "githubactions_ecr_access_role" {
  name = "${var.pjname}-githubactions-ecr-access-role"
  
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

resource "aws_iam_role_policy" "githubactions_ecr_access_role_policy" {
  name = "${aws_iam_role.githubactions_assume_role.name}-policy"
  role = aws_iam_role.githubactions_assume_role.id

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
