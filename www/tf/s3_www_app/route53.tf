# https://www.milanvit.net/post/terraform-recipes-cloudfront-distribution-from-s3-bucket/


###################################
# Route 53 - Domain record
###################################
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

