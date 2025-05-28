data "aws_caller_identity" "self" {}

# 2025/05/28時点で、EKS Pod Identityに未対応
# https://github.com/openobserve/openobserve/issues/3987

# resource "aws_eks_pod_identity_association" "openobserve_access_identity_association" {
#   for_each = toset(var.eks_cluster_name)

#   cluster_name    = each.value
#   namespace       = var.namespace
#   service_account = "openobserve"
#   role_arn        = aws_iam_role.openobserve_access_role.arn
# }

data "aws_iam_policy_document" "openobserve_access_role_document" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = var.eks_oidc_provider_arns
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc}:sub"
      values   = ["system:serviceaccount:${var.namespace}:openobserve"]
    }
  }
}

data "aws_iam_policy_document" "openobserve_access_policy_document" {

  statement {
    actions = [
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.openobserve_bucket.bucket}/*"
    ]
  }
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.openobserve_bucket.bucket}"
    ]
  }
}

resource "aws_iam_role" "openobserve_access_role" {
  name               = "${var.pjname}-openobserve-access-role"
  assume_role_policy = data.aws_iam_policy_document.openobserve_access_role_document.json
}

resource "aws_iam_policy" "openobserve_access_policy" {
  name   = "${var.pjname}-openobserve-access-policy"
  policy = data.aws_iam_policy_document.openobserve_access_policy_document.json
}

resource "aws_iam_role_policy_attachment" "openobserve_access_policy_attachment" {
  role       = aws_iam_role.openobserve_access_role.name
  policy_arn = aws_iam_policy.openobserve_access_policy.arn
}

resource "aws_s3_bucket" "openobserve_bucket" {
  bucket = "${var.pjname}-openobserve-${var.region}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "openobserve_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.openobserve_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "openobserve_bucket_versioning" {
  bucket = aws_s3_bucket.openobserve_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "openobserve_bucket_public_access" {
  bucket                  = aws_s3_bucket.openobserve_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
