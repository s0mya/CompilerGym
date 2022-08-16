# TODO pull out the ALB into it's own module to allow multiple target groups (1 for each model) to be added to the ALB.

# note that this creates the alb, target group, and access logs
# the listeners are defined in lb-http.tf and lb-https.tf
# delete either of these if your app doesn't need them
# but you need at least one


# variable "lb_access_logs_expiration_days" {
#   default = "3"
# }


resource "aws_lb" "alb" {
  name = replace("${var.app}-${var.environment}-alb", "_", "-")

  # launch lbs in public or private subnets based on "internal" variable
  subnets = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  security_groups = [data.aws_security_group.default.id, data.aws_security_group.admin-fb-corp.id]

  # enable access logs in order to get support from aws
  # access_logs {
  #   enabled = true
  #   bucket  = aws_s3_bucket.aws_logs.bucket
  #   prefix  = "api_lb"
  # }

}

#############################################################
# Associate API Load Balancer to the API Application Firewall
#############################################################
# resource "aws_wafv2_web_acl_association" "alb_waf" {
#   resource_arn = aws_lb.alb.arn
#   web_acl_arn  = data.aws_wafv2_web_acl.api.arn
# }


#############################################################
# Associate API Load Balancer to Route 53 domain
#############################################################
resource "aws_route53_record" "api_domain" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.api_domain
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
