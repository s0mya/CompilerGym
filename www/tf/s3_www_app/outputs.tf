
output "www_cloudfront_id" {
    value = aws_cloudfront_distribution.cdn.id
}

output "www_bucket" {
    value = aws_s3_bucket.www.id
}