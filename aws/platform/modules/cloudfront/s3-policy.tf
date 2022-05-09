resource "aws_s3_bucket_policy" "static_web_bucket_policy" {
  bucket = aws_s3_bucket.static_web_bucket.id

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.origin_access_identity.id}"
        },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.static_web_bucket.id}/*"
    }
  ]
}
POLICY
}