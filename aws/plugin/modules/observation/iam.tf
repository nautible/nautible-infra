resource "aws_iam_policy" "mimir_bucket_policy" {
  name = "${var.pjname}-${var.region}-mimir-bucket-policy"

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
          "arn:aws:s3:::${aws_s3_bucket.mimir_ruler_bucket.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.mimir_tsdb_bucket.bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.mimir_ruler_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.mimir_tsdb_bucket.bucket}"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "tempo_bucket_policy" {
  name = "${var.pjname}-${var.region}-tempo-bucket-policy"

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
          "arn:aws:s3:::${aws_s3_bucket.tempo_bucket.bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.tempo_bucket.bucket}"
        ]
      }
    ]
  })
}

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

resource "aws_iam_role" "observability_role" {
  name = "${var.pjname}-observability-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sts:TagSession",
          "sts:AssumeRole"
        ],
        Principal = {
          "Service" : "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mimir_bucket_policy_attachment" {
  role       = aws_iam_role.observability_role.name
  policy_arn = aws_iam_policy.mimir_bucket_policy.arn
}

resource "aws_iam_role_policy_attachment" "tempo_bucket_policy_attachment" {
  role       = aws_iam_role.observability_role.name
  policy_arn = aws_iam_policy.tempo_bucket_policy.arn
}

resource "aws_iam_role_policy_attachment" "loki_bucket_policy_attachment" {
  role       = aws_iam_role.observability_role.name
  policy_arn = aws_iam_policy.loki_bucket_policy.arn
}

