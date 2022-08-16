# https://www.milanvit.net/post/terraform-recipes-cloudfront-distribution-from-s3-bucket/


###################################
# S3 Bucket - WWW
###################################
resource "aws_s3_bucket" "www" {
  bucket              = replace("${var.environment}-${var.app}-www", "_", "-")
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
