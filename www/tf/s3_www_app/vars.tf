# Global Vars
variable "environment" {
  type = string
}

variable "app" {
  type = string
}

variable "app_service" {
  type = string
}

variable "www_domain" {
  type = string
}

variable "www_cert_arn" {
  type = string
}

variable "www_waf_acl_arn" {
  type = string
  description = "The WAF ARN"
}

variable "route53_hosted_zone" {
  type = string
}
