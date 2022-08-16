

###################################
# Route 53 - Hosted Zone Lookup
###################################
data "aws_route53_zone" "main" {
  name = var.route53_hosted_zone
}
