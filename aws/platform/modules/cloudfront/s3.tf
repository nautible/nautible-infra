# don't use terraform-aws-modules/s3-bucket/aws because 
# can't set lifecycle attribute
resource "aws_s3_bucket" "static_web_bucket" {
  bucket = "${var.pjname}-static-web-${var.region}"
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_web_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.static_web_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_public_access_block" "static_web_bucket_public_access" {
  bucket                  = aws_s3_bucket.static_web_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.static_web_bucket]
}

#resource "aws_s3_bucket" "cloudfront-log-bucket" {
#  bucket = "${var.pjname}-cloudfront-log"
#
#  server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        sse_algorithm = "AES256"
#      }
#    }
#  }
#  lifecycle {
#    prevent_destroy = true
#  }
#}

#resource "aws_s3_bucket_public_access_block" "cloudfront-log-bucket-public-access" {
#  bucket                  = aws_s3_bucket.cloudfront-log-bucket.id
#  block_public_acls       = true
#  block_public_policy     = true
#  ignore_public_acls      = true
#  restrict_public_buckets = true
#}
