resource "aws_s3_bucket" "mimir_ruler_bucket" {
  bucket = "${var.pjname}-mimir-${var.region}-ruler"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mimir_ruler_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.mimir_ruler_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "mimir_ruler_bucket_versioning" {
  bucket = aws_s3_bucket.mimir_ruler_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "mimir_ruler_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.mimir_ruler_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "mimir_tsdb_bucket" {
  bucket = "${var.pjname}-mimir-${var.region}-tsdb"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mimir_tsdb_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.mimir_tsdb_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "mimir_tsdb_bucket_versioning" {
  bucket = aws_s3_bucket.mimir_tsdb_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "mimir_tsdb_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.mimir_tsdb_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
