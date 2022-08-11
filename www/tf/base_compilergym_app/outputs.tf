# The load balancer DNS name
output "lb_dns" {
  value = aws_alb.api.dns_name
}

output "www_s3_bucket" {
  value       = aws_s3_bucket.www.bucket
  description = "WWW S3 Bucket"
}

output "www_cloudfront_id" {
  value       = aws_cloudfront_distribution.cdn.id
  description = "WWW Cloudfront ID"
}
