resource "aws_iam_policy" "loki_bucket_policy" {
  name = "${var.pjname}-${var.region}-loki-bucket-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging",
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.loki_chunks_bucket.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.loki_ruler_bucket.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.loki_admin_bucket.bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.loki_chunks_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.loki_ruler_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.loki_admin_bucket.bucket}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "loki_bucket_role" {
  name = "${var.pjname}-loki-bucket-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRoleWithWebIdentity",
        Principal = {
          Federated = var.eks_oidc_provider_arns
        }
        Condition = {
          StringEquals = {
            "${var.oidc}:sub" = "system:serviceaccount:monitoring:loki-sa",
            "${var.oidc}:aud" = "sts.amazonaws.com"

          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "loki_bucket_policy_attachment" {
  role       = aws_iam_role.loki_bucket_role.name
  policy_arn = aws_iam_policy.loki_bucket_policy.arn
}

