
###################################
# CloudFront - Origin Access Identity
###################################
resource "aws_cloudfront_origin_access_identity" "compilergym-www-oai" {
  comment = "${var.environment}-${var.app}-www-oai"
}

###################################
# IAM Policy Document
###################################
data "aws_iam_policy_document" "read_www_bucket" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.compilergym-www-oai.iam_arn]
    }
  }

  #   statement {
  #     actions   = ["s3:ListBucket"]
  #     resources = [aws_s3_bucket.gitbook.arn]

  #     principals {
  #       type        = "AWS"
  #       identifiers = [aws_cloudfront_origin_access_identity.nllb-www-oai.iam_arn]
  #     }
  #   }
}

###################################
# S3 Bucket - WWW
###################################
resource "aws_s3_bucket" "www" {
  bucket              = "${var.environment}-${var.app}-www"
  object_lock_enabled = false
}


###################################
# S3 Bucket ACL
###################################
resource "aws_s3_bucket_acl" "www" {
  bucket = aws_s3_bucket.www.id
  acl    = "private"
}

###################################
# S3 Bucket Public access
# Keep s3 buckets private
###################################
resource "aws_s3_bucket_public_access_block" "s3Public" {
  bucket                  = aws_s3_bucket.www.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

###################################
# S3 Bucket Policy
###################################
resource "aws_s3_bucket_policy" "read_www" {
  bucket = aws_s3_bucket.www.id
  policy = data.aws_iam_policy_document.read_www_bucket.json
}


###################################
# Cloudfront Distribution
###################################
resource "aws_cloudfront_distribution" "cdn" {
  aliases = [
    "${var.www_domain}",
  ]
  comment             = var.www_domain
  enabled             = true
  default_root_object = "index.html"
  web_acl_id          = aws_wafv2_web_acl.www.arn

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = true
    min_ttl                = 0
    default_ttl            = 5 * 60
    max_ttl                = 60 * 60
    smooth_streaming       = false
    target_origin_id       = aws_s3_bucket.www.bucket
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.www.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.www.bucket



    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.compilergym-www-oai.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }




  viewer_certificate {
    acm_certificate_arn = var.www_cert_arn
    #   cloudfront_default_certificate = false
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

data "aws_route53_zone" "main" {
  name = var.route53_hosted_zone
}

resource "aws_route53_record" "www_domain" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.www_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
