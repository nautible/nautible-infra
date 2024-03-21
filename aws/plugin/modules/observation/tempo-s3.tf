resource "aws_s3_bucket" "tempo_bucket" {
  bucket = "${var.pjname}-tempo-${var.region}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tempo_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.tempo_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "tempo_bucket_versioning" {
  bucket = aws_s3_bucket.tempo_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tempo_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.tempo_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
