# OIDC Provider
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  count           = var.oidc.oidc_provider_arn == "" ? 1 : 0
  url             = var.oidc.url
  client_id_list  = var.oidc.client_id_list
  thumbprint_list = var.oidc.thumbprint_list
}

resource "aws_iam_role" "githubactions_ecr_access_role" {
  name = "${var.pjname}-githubactions-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRoleWithWebIdentity",
        Principal = {
          Federated = var.oidc.oidc_provider_arn == "" ? aws_iam_openid_connect_provider.oidc_provider[0].id : var.oidc.oidc_provider_arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_organization}/*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "githubactions_ecr_access_role_policy" {
  name = "${aws_iam_role.githubactions_ecr_access_role.name}-policy"
  role = aws_iam_role.githubactions_ecr_access_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
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
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "githubactions_infra_role" {
  name = "${var.pjname}-githubactions-infra-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRoleWithWebIdentity",
        Principal = {
          Federated = var.oidc.oidc_provider_arn == "" ? aws_iam_openid_connect_provider.oidc_provider[0].id : var.oidc.oidc_provider_arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_organization}/*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "githubactions_infra_role_attach" {
  role       = aws_iam_role.githubactions_infra_role.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "githubactions_infra_role_policy" {
  name = "${aws_iam_role.githubactions_infra_role.name}-policy"
  role = aws_iam_role.githubactions_infra_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sts:GetServiceBearerToken",
          "ec2:*",
          "elasticloadbalancing:*",
          "s3:*",
          "ecr:*",
          "eks:*",
          "cloudfront:*",
          "sqs:*",
          "sns:*",
          "rds:*",
          "dynamodb:*",
          "elasticache:*",
          "route53:*",
          "acm:*",
          "cloudwatch:*",
          "logs:*",
          "iam:CreatePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:DeletePolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:UpdateRole",
          "iam:PutRolePolicy",
          "iam:TagRole",
          "iam:TagPolicy",
          "iam:CreateUser"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = "*",
        Condition = {
          StringEquals = {
            "iam:PassToService" = "eks.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "githubactions_static_web_deploy_role" {
  name = "${var.pjname}-githubactions-static-web-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRoleWithWebIdentity",
        Principal = {
          Federated = var.oidc.oidc_provider_arn == "" ? aws_iam_openid_connect_provider.oidc_provider[0].id : var.oidc.oidc_provider_arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_organization}/*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "githubactions_static_web_deploy_role_policy" {
  name = "${aws_iam_role.githubactions_static_web_deploy_role.name}-policy"
  role = aws_iam_role.githubactions_static_web_deploy_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.static_web_bucket_id}/*",
          "arn:aws:s3:::${var.static_web_bucket_id}"
        ]
      }
    ]
  })
}
