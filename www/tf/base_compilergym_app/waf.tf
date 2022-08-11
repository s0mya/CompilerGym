
#############################################################
# AWS Provider for US East 1 - To enable global WAF, Cloudfront setup
#############################################################
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = {
      env    = var.environment
      demo   = var.app
      oncall = "ai-playground"
    }
  }
}


#############################################################
# Rules for FB IP addresses - Defined in FB Account
#############################################################
data "aws_ec2_managed_prefix_list" "fb_corp_ipv4" {
  name = "fb-corp-prefix-ipv4-list"
}
data "aws_ec2_managed_prefix_list" "fb_corp_ipv6" {
  name = "fb-corp-prefix-ipv6-list"
}


#############################################################
# Rules for FB IP addresses - GLOBAL FOR WWW
#############################################################
resource "aws_wafv2_ip_set" "fb_corp_ipv4" {

  provider           = aws.us-east-1 # Using "GLOBAL (us-east-1) AWS provider"
  name               = "${var.environment}-${var.app}-global-fb_corp_ipv4"
  description        = "${var.environment}-${var.app}-global-fb_corp_ipv4"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = [for e in data.aws_ec2_managed_prefix_list.fb_corp_ipv4.entries : e.cidr]


}
resource "aws_wafv2_ip_set" "fb_corp_ipv6" {
  provider           = aws.us-east-1 # Using "GLOBAL (us-east-1) AWS provider"
  name               = "${var.environment}-${var.app}-global-fb_corp_ipv6"
  description        = "fb_corp_ipv6"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV6"
  addresses          = [for e in data.aws_ec2_managed_prefix_list.fb_corp_ipv6.entries : e.cidr]
}

#############################################################
# Rules for FB IP addresses - REGIONAL FOR API
#############################################################
resource "aws_wafv2_ip_set" "fb_corp_ipv4_regional" {
  name               = "${var.environment}-${var.app}-${var.region}-fb_corp_ipv4"
  description        = "fb_corp_ipv4"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = [for e in data.aws_ec2_managed_prefix_list.fb_corp_ipv4.entries : e.cidr]

}
resource "aws_wafv2_ip_set" "fb_corp_ipv6_regional" {
  name               = "${var.environment}-${var.app}-${var.region}-fb_corp_ipv6"
  description        = "fb_corp_ipv6"
  scope              = "REGIONAL"
  ip_address_version = "IPV6"
  addresses          = [for e in data.aws_ec2_managed_prefix_list.fb_corp_ipv6.entries : e.cidr]
}



#############################################################
# Web Apllication Firewall (WAF) for WWW
#############################################################
resource "aws_wafv2_web_acl" "www" {
  provider    = aws.us-east-1 # Using "GLOBAL (us-east-1) AWS provider"
  name        = "${var.environment}-${var.app}-www-acl"
  description = "Firewall for ${var.environment} ${var.app} WWW"
  scope       = "CLOUDFRONT"

  # Create an "allow" or "block" block depending on `public_facing`
  # See https://github.com/hashicorp/terraform/issues/26701
  default_action {
    dynamic "allow" {
      for_each = var.waf_public_facing ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = var.waf_public_facing ? [] : [1]
      content {}
    }
  }

  rule {
    name     = "allow_fb_corp"
    priority = 1

    action {
      allow {}
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.fb_corp_ipv4.arn
          }
        }
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.fb_corp_ipv6.arn
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "allow_fb_corp"
      sampled_requests_enabled   = false
    }
  }



  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.environment}-${var.app}"
    sampled_requests_enabled   = true
  }
}

#############################################################
# Cloudwatch Logging for WWW WAF
#############################################################
resource "aws_cloudwatch_log_group" "waf_www" {
  provider = aws.us-east-1 # Using "GLOBAL (us-east-1) AWS provider"
  # // Prefix "aws-waf-logs-" is required https://docs.aws.amazon.com/waf/latest/developerguide/logging-cw-logs.html
  name              = "aws-waf-logs-${var.environment}-${var.app}-www"
  retention_in_days = 90
}

resource "aws_wafv2_web_acl_logging_configuration" "www" {
  provider                = aws.us-east-1 # Using "GLOBAL (us-east-1) AWS provider"
  log_destination_configs = [aws_cloudwatch_log_group.waf_www.arn]
  resource_arn            = aws_wafv2_web_acl.www.arn
  redacted_fields {
    single_header {
      name = "user-agent"
    }
  }
}




#############################################################
# Web Apllication Firewall for API -
#############################################################
resource "aws_wafv2_web_acl" "api" {

  name        = "${var.environment}-${var.app}-api-acl"
  description = "Firewall for ${var.environment} ${var.app} API"
  scope       = "REGIONAL"


  # Create an "block" block depending on `public_facing`
  # See https://github.com/hashicorp/terraform/issues/26701
  default_action {
    block {
    }
  }

  # Allow all traffic from FB corp
  rule {
    name     = "allow_from_fb_corp"
    priority = 1
    action {
      allow {}
    }

    statement {
      or_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.fb_corp_ipv4_regional.arn
          }
        }
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.fb_corp_ipv6_regional.arn
          }
        }
      }
    }


    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "allow_from_fb_corp"
      sampled_requests_enabled   = false
    }
  }

  # Allow only traffic from public to "/api"
  rule {
    name     = "allow_api_from_public"
    priority = 2

    action {
      dynamic "allow" {
        for_each = var.waf_public_facing ? [1] : []
        content {}
      }
      dynamic "block" {
        for_each = var.waf_public_facing ? [] : [1]
        content {}
      }
    }

    statement {
      byte_match_statement {

        positional_constraint = "STARTS_WITH"
        search_string         = "/api"

        field_to_match {
          uri_path {}
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "allow_api_from_public"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.environment}-${var.app}-api"
    sampled_requests_enabled   = true
  }
}




#############################################################
# Cloudwatch Logging for WWW API
#############################################################
resource "aws_cloudwatch_log_group" "waf_api" {
  # // Prefix "aws-waf-logs-" is required https://docs.aws.amazon.com/waf/latest/developerguide/logging-cw-logs.html
  name              = "aws-waf-logs-${var.environment}-${var.app}-api"
  retention_in_days = 90
}

resource "aws_wafv2_web_acl_logging_configuration" "api" {
  log_destination_configs = [aws_cloudwatch_log_group.waf_api.arn]
  resource_arn            = aws_wafv2_web_acl.api.arn
  redacted_fields {
    single_header {
      name = "user-agent"
    }
  }
}
