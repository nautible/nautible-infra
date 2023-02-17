resource "aws_s3_bucket" "backup_bucket" {
  count  = try(var.backup_bucket_create, "") != "" ? 1 : 0
  bucket = var.backup_bucket_name
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup_bucket_server_side_encryption" {
  count  = try(var.backup_bucket_create, "") != "" ? 1 : 0
  bucket = aws_s3_bucket.backup_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "backup_bucket_versioning" {
  count  = try(var.backup_bucket_create, "") != "" ? 1 : 0
  bucket = aws_s3_bucket.backup_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "backup_bucket_public_access" {
  count                   = try(var.backup_bucket_create, "") != "" ? 1 : 0
  bucket                  = aws_s3_bucket.backup_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role_policy" "backup_policy" {
  for_each = var.eks_cluster_name_node_role_name_map
  name     = "${each.key}-eks-backup-policy"
  role     = each.value

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "VeleroBackupBucket",
        Action = [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${aws_s3_bucket.backup_bucket.bucket}/*"
      },
      {
        Sid    = "VeleroBackupListBucket",
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.backup_bucket.bucket}"
      },
      {
        Sid    = "VeleroBackupEc2",
        Effect = "Allow",
        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot"
        ]
        Resource = "*"
      }
    ]
  })
}