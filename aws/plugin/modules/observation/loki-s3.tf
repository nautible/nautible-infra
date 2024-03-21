resource "aws_s3_bucket" "loki_bucket" {
  bucket = "${var.pjname}-loki-${var.region}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.loki_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "loki_bucket_versioning" {
  bucket = aws_s3_bucket.loki_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "loki_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.loki_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
