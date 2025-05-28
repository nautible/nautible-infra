resource "aws_s3_bucket" "loki_chunks_bucket" {
  bucket = "${var.pjname}-loki-${var.region}-chunks"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki_chunks_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.loki_chunks_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "loki_chunks_bucket_versioning" {
  bucket = aws_s3_bucket.loki_chunks_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "loki_chunks_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.loki_chunks_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "loki_ruler_bucket" {
  bucket = "${var.pjname}-loki-${var.region}-ruler"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki_ruler_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.loki_ruler_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "loki_ruler_bucket_versioning" {
  bucket = aws_s3_bucket.loki_ruler_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "loki_ruler_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.loki_ruler_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "loki_admin_bucket" {
  bucket = "${var.pjname}-loki-${var.region}-admin"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki_admin_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.loki_admin_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "loki_admin_bucket_versioning" {
  bucket = aws_s3_bucket.loki_admin_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "loki_admin_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.loki_admin_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
