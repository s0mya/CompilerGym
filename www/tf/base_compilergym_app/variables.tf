
variable "environment" {
  description = "Environment"
  type        = string
}

variable "app" {

  description = "The name of the app"
  type        = string
}

variable "account_id" {
  description = "the AWS Account ID"
  type        = string
}


variable "region" {

  description = "the AWS region"
  type        = string
}


variable "container_port" {

  type = number
}

# The port the load balancer will listen on
variable "api_lb_port" {

}

# The load balancer protocol
variable "api_lb_protocol" {

}

# WWW route
variable "www_domain" {

}
# API route
variable "api_domain" {

}

variable "route53_hosted_zone" {

  description = "The hosted zone for lookup and added the www domain"
}

variable "www_cert_arn" {

  description = "the Cert to use, must always be us-east-1"
}

variable "api_cert_arn" {

  description = "the Cert to use, must always be for var.region"
}
variable "waf_public_facing" {
  type        = bool
  description = "If the WAF (firewall) can be public facing."
}

variable "ecr_image" {
  type        = string
  description = "API Task ECR Image"
}
