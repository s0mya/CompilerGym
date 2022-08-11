
output "www_url" {
  value = "https://${var.www_domain}"
}
# The load balancer DNS name
output "api_url" {
  value = "https://${var.api_domain}"
}


output "www_s3_bucket" {
  value       = module.compilergym_app_prod.www_s3_bucket
  description = "WWW S3 Bucket"
}

output "www_cloudfront_id" {
  value       = module.compilergym_app_prod.www_cloudfront_id
  description = "WWW Cloudfront ID"
}
