
###################################
# S3 bucket for storing  logs
###################################
resource "aws_s3_bucket" "aws_logs" {
  bucket = "${var.environment}-${var.app}-logs"
}

# resource "aws_s3_bucket" "aws_logs" {
#   bucket        = var.s3_bucket_name
#   force_destroy = var.force_destroy

#   tags = merge(
#     var.tags, {
#       Name = var.s3_bucket_name
#     }
#   )
# }

data "aws_elb_service_account" "main" {
}

# give load balancing service access to the bucket
resource "aws_s3_bucket_policy" "aws_logs_access" {
  bucket = aws_s3_bucket.aws_logs.id

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.aws_logs.arn}",
        "${aws_s3_bucket.aws_logs.arn}/*"
      ],
      "Principal": {
        "AWS": [ "${data.aws_elb_service_account.main.arn}" ]
      }
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_acl" "aws_logs" {
  bucket = aws_s3_bucket.aws_logs.id
  #   Set bucket ACL per [AWS S3 Canned ACL](<https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl>) list
  acl = "log-delivery-write"
}

resource "aws_s3_bucket_lifecycle_configuration" "aws_logs" {
  bucket = aws_s3_bucket.aws_logs.id

  rule {
    id     = "expire_all_logs"
    status = "Enabled"

    filter {
      prefix = "/*"
    }

    expiration {
      days = 90
    }

    # noncurrent_version_expiration {
    #   noncurrent_days = var.noncurrent_version_retention
    # }
  }
}

# resource "aws_s3_bucket_server_side_encryption_configuration" "aws_logs" {
#   bucket = aws_s3_bucket.aws_logs.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_s3_bucket_logging" "aws_logs" {
#   count = var.logging_target_bucket != "" ? 1 : 0

#   bucket = aws_s3_bucket.aws_logs.id

#   target_bucket = var.logging_target_bucket
#   target_prefix = var.logging_target_prefix
# }

# resource "aws_s3_bucket_versioning" "aws_logs" {
#   bucket = aws_s3_bucket.aws_logs.id
#   versioning_configuration {
#     status     = var.versioning_status
#     mfa_delete = var.enable_mfa_delete ? "Enabled" : null
#   }
# }

resource "aws_s3_bucket_public_access_block" "public_access_block" {

  bucket = aws_s3_bucket.aws_logs.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}
