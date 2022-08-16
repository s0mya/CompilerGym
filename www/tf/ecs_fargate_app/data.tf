resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "${var.region}b"

  tags = {
    Name = "Default subnet for ${var.region}b"
  }
}


resource "aws_default_subnet" "default_az2" {
  availability_zone = "${var.region}c"

  tags = {
    Name = "Default subnet for ${var.region}c"
  }
}


data "aws_security_group" "admin-fb-corp" {
  name = var.security_group_name
}

data "aws_security_group" "default" {
  name = "default"
}


data "aws_route53_zone" "main" {
  name = var.route53_hosted_zone
}


# data "aws_wafv2_web_acl" "api" {
#   name  = var.waf_name
#   scope = "REGIONAL"
# }
