# don't use terraform-aws-modules/cloudfront/aws, because
# can't get origin access identity id

locals {
  s3_origin_id = "${var.pjname}-s3-static-web"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.pjname}-s3-static-web-origin-access-identity"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  count = var.cloudfront_origin_dns_name == "" ? 0 : 1
  origin {
    domain_name = "${var.pjname}-static-web-${var.region}.s3.amazonaws.com"
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }


  origin {
    domain_name = var.cloudfront_origin_dns_name
    origin_id   = "aws-load-balancer-controller"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2", ]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.pjname}-cloudfront"
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  wait_for_deployment = true

  #aliases = [join("",[ replace(var.pjname, "-", "") , ".cloudfront.net"])]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    compress         = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]
    default_ttl     = 0
    max_ttl         = 0
    # min_ttl = 0
    path_pattern           = var.service_api_path_pattern
    target_origin_id       = "aws-load-balancer-controller"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "${var.pjname}-cloudfront"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}